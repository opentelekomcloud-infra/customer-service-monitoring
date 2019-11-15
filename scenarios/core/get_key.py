import os
from argparse import ArgumentParser

from boto3.session import Session
from botocore.exceptions import ClientError
from cryptography.hazmat.backends import default_backend as crypto_default_backend
from cryptography.hazmat.primitives import serialization as crypto_serialization
from cryptography.hazmat.primitives.asymmetric import rsa

api_endpoint = 'https://obs.eu-de.otc.t-systems.com'
bucket = 'obs-csm'


def parse_params():
    parser = ArgumentParser('OpenTelekomCloud S3 key downloader')
    parser.add_argument('--key', '-k', default=None)
    parser.add_argument('--output', '-o', default=None)
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


RO_OWNER = 0o400


def copy_key_from_s3():
    args = parse_params()
    session = Session(aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'])
    s3 = session.resource('s3', endpoint_url=api_endpoint)
    output_file = args.output
    try:
        s3.Bucket(bucket).download_file(args.key, output_file)
        os.chmod(output_file, RO_OWNER)
    except ClientError as e:
        if e.response['Error']['Code'] == '404':
            print('The object does not exist in s3. Generating new one ...')
            key = generate_private_key()
            obj = s3.Object(bucket, args.key)
            obj.put(Body=key)
            with open(output_file, 'wb') as file:
                file.write(key)
            os.chmod(output_file, RO_OWNER)
        else:
            raise


if __name__ == '__main__':
    copy_key_from_s3()
