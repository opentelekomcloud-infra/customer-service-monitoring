import os
from argparse import ArgumentParser

from boto3.session import Session
from botocore.exceptions import ClientError

api_endpoint = 'https://obs.eu-de.otc.t-systems.com'
bucket = "obs-csm"


def parse_params():
    parser = ArgumentParser('OpenTelekomCloud S3 key downloader')
    parser.add_argument('--key', '-k', default=None)
    parser.add_argument('--output', '-o', default=None)
    args = parser.parse_args()
    return args


def copy_key_from_s3():
    args = parse_params()
    session = Session(aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'])
    s3 = session.resource('s3', endpoint_url=api_endpoint)
    try:
        s3.Bucket(bucket).download_file(args.key, args.output)
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The object does not exist.")
        else:
            raise


if __name__ == '__main__':
    copy_key_from_s3()
