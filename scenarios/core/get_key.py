#!/usr/bin/env python3
import hashlib
import os
from argparse import ArgumentParser

from boto3.session import Session
from botocore.exceptions import ClientError
from cryptography.hazmat.backends import default_backend as crypto_default_backend
from cryptography.hazmat.primitives import serialization as crypto_serialization
from cryptography.hazmat.primitives.asymmetric import rsa

S3_ENDPOINT = 'https://obs.eu-de.otc.t-systems.com'
BUCKET = 'obs-csm'
RW_OWNER = 0o600


def parse_params():
    parser = ArgumentParser(description='Synchronize used private key with OBS')
    parser.add_argument('--key', '-k', required=True)
    parser.add_argument('--output', '-o', required=True)
    args = parser.parse_args()
    return args


def generate_private_key():
    key = rsa.generate_private_key(
        backend=crypto_default_backend(),
        public_exponent=65537,
        key_size=2048
    )
    return key.private_bytes(
        crypto_serialization.Encoding.PEM,
        crypto_serialization.PrivateFormat.TraditionalOpenSSL,
        crypto_serialization.NoEncryption())


def requires_update(file_name, remote_md5):
    if not os.path.isfile(file_name):
        return True
    with open(file_name, 'rb') as trg_file:
        md5 = hashlib.md5(trg_file.read()).hexdigest()
    return remote_md5 != md5


def get_key_from_s3() -> str:
    """Download existing key from s3 or create a new one and upload"""
    args = parse_params()
    session = Session(aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'])
    output_file = args.output
    key_name = args.key
    obs = session.resource('s3', endpoint_url=S3_ENDPOINT)
    bucket = obs.Bucket(BUCKET)
    try:
        file_md5 = bucket.Object(key_name).e_tag[1:-1]
        if requires_update(output_file, file_md5):
            bucket.download_file(key_name, output_file)
        return output_file
    except ClientError as cl_e:
        if cl_e.response['Error']['Code'] == '404':
            print('The object does not exist in s3. Generating new one ...')
            key = generate_private_key()
            obj = obs.Object(BUCKET, key_name)
            obj.put(Body=key)
            with open(output_file, 'wb') as file:
                file.write(key)
            return output_file


if __name__ == '__main__':
    os.chmod(get_key_from_s3(), RW_OWNER)
