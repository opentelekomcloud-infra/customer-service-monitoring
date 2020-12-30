#!/usr/bin/env python3
import hashlib
import os
from argparse import ArgumentParser
from dataclasses import dataclass

import requests
from boto3.session import Session
from botocore.exceptions import ClientError
from cryptography.hazmat.backends import default_backend as crypto_default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.asymmetric.rsa import (
    RSAPrivateKeyWithSerialization,
    RSAPublicKey
)
from openstack.config import OpenStackConfig

S3_ENDPOINT = 'https://obs.eu-de.otc.t-systems.com'
BUCKET = 'obs-csm'
RW_OWNER = 0o600


def parse_params():
    parser = ArgumentParser(description='Synchronize used private key with OBS')
    parser.add_argument('--key', '-k', required=True)
    parser.add_argument('--output', '-o', required=True)
    parser.add_argument('--local', action='store_true', default=False)
    args = parser.parse_args()
    return args


def generate_key_pair(default_private: bytes = None):
    """Generate key pair as tuple of bytes"""
    rsa_backend = crypto_default_backend()
    if default_private is None:
        private_key: RSAPrivateKeyWithSerialization = rsa.generate_private_key(
            backend=rsa_backend,
            public_exponent=65537,
            key_size=2048
        )
    else:
        private_key = serialization.load_pem_private_key(default_private, None, rsa_backend)
    public_key: RSAPublicKey = private_key.public_key()

    # noinspection PyTypeChecker
    private_bytes: bytes = private_key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.TraditionalOpenSSL,
        serialization.NoEncryption()
    )
    # noinspection PyTypeChecker
    public_bytes: bytes = public_key.public_bytes(serialization.Encoding.OpenSSH,
                                                  serialization.PublicFormat.OpenSSH)
    return private_bytes, public_bytes


def requires_update(file_name, remote_md5):
    """Check if local file is not up to date with remote"""
    if not os.path.isfile(file_name):
        return True
    with open(file_name, 'rb') as trg_file:
        md5 = hashlib.md5(trg_file.read()).hexdigest()
    return remote_md5 != md5


def _generate_new_pair(private_key_file: str) -> bytes:
    private_key, key_pub = generate_key_pair()
    with open(private_key_file, 'wb') as file:
        file.write(private_key)
    with open(f'{private_key_file}.pub', 'wb') as file_pub:
        file_pub.write(key_pub)
    return private_key


def _generate_pub_for_private(private_key_file: str):
    with open(private_key_file, 'rb') as file:
        private_key = file.read()
    _, key_pub = generate_key_pair(private_key)
    with open(f'{private_key_file}.pub', 'wb') as file_pub:
        file_pub.write(key_pub)


@dataclass
class Credential:
    """Container for credential"""

    access: str
    secret: str
    security_token: str


def get_key_from_s3(key_file, key_name, credential: Credential) -> str:
    """Download existing key from s3 or create a new one and upload"""

    session = Session(aws_access_key_id=credential.access,
                      aws_secret_access_key=credential.secret,
                      aws_session_token=credential.security_token)

    obs = session.resource('s3', endpoint_url=S3_ENDPOINT)
    bucket = obs.Bucket(BUCKET)
    try:
        file_md5 = bucket.Object(key_name).e_tag[1:-1]
    except ClientError as cl_e:
        if cl_e.response['Error']['Code'] == '404':
            print('The object does not exist in s3. Generating new one...')
            private_key = _generate_new_pair(key_file)
            obj = obs.Object(BUCKET, key_name)
            obj.put(Body=private_key)
            return key_file
        raise cl_e

    if requires_update(key_file, file_md5):
        bucket.download_file(key_name, key_file)
        _generate_pub_for_private(key_file)
        print('Private key downloaded')
    else:
        _generate_pub_for_private(key_file)
        print('Private key is up to date')
    return key_file


def _session_token_request():
    return {
        'auth': {
            'identity': {
                'methods': [
                    'token'
                ],
                'token': {
                    'duration-seconds': '900',
                }
            }
        }
    }


def _get_session_token(auth_url, os_token) -> Credential:
    v30_url = auth_url.replace('/v3', '/v3.0')
    token_url = f'{v30_url}/OS-CREDENTIAL/securitytokens'

    auth_headers = {'X-Auth-Token': os_token}

    response = requests.post(token_url, headers=auth_headers, json=_session_token_request())
    if response.status_code != 201:
        raise RuntimeError('Failed to get temporary AK/SK:', response.text)
    data = response.json()['credential']
    return Credential(data['access'], data['secret'], data['securitytoken'])


def acquire_temporary_ak_sk() -> Credential:
    """Get temporary AK/SK using password auth"""
    os_config = OpenStackConfig()
    cloud = os_config.get_one()

    iam_session = cloud.get_session()
    auth_url = iam_session.get_endpoint(service_type='identity')
    os_token = iam_session.get_token()
    return _get_session_token(auth_url, os_token)


def main():
    """Run the script"""
    args = parse_params()

    key_file = args.output
    if args.local:
        _generate_new_pair(key_file)
        print('Generated local key pair:', key_file)
    else:
        credential = acquire_temporary_ak_sk()
        key_file = get_key_from_s3(key_file, args.key, credential)
    os.chmod(key_file, RW_OWNER)


if __name__ == '__main__':
    main()
