#!/usr/bin/env python3
import hashlib
import os
from argparse import ArgumentParser

from boto3.session import Session
from botocore.exceptions import ClientError
from cryptography.hazmat.backends import default_backend as crypto_default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateKeyWithSerialization, RSAPublicKey

S3_ENDPOINT = 'https://obs.eu-de.otc.t-systems.com'
BUCKET = 'obs-csm'
RW_OWNER = 0o600


def parse_params():
    parser = ArgumentParser(description='Synchronize used private key with OBS')
    parser.add_argument('--key', '-k', required=True)
    parser.add_argument('--output', '-o', required=True)
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

    private_bytes: bytes = private_key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.TraditionalOpenSSL,
        serialization.NoEncryption()
    )
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


def get_key_from_s3() -> str:
    """Download existing key from s3 or create a new one and upload"""
    args = parse_params()
    session = Session(aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'])
    private_key_file = args.output
    key_name = args.key
    obs = session.resource('s3', endpoint_url=S3_ENDPOINT)
    bucket = obs.Bucket(BUCKET)
    try:
        file_md5 = bucket.Object(key_name).e_tag[1:-1]
    except ClientError as cl_e:
        if cl_e.response['Error']['Code'] == '404':
            print('The object does not exist in s3. Generating new one...')
            private_key = _generate_new_pair(private_key_file)
            obj = obs.Object(BUCKET, key_name)
            obj.put(Body=private_key)
            return private_key_file
        raise cl_e

    if requires_update(private_key_file, file_md5):
        bucket.download_file(key_name, private_key_file)
        _generate_pub_for_private(private_key_file)
        print('Private key downloaded')
    else:
        print('Private key is up to date')
    return private_key_file


if __name__ == '__main__':
    os.chmod(get_key_from_s3(), RW_OWNER)
