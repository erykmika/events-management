from logging import getLogger
from typing import Any
import os

import boto3
from botocore.exceptions import ClientError


from backend.settings import get_settings

logger = getLogger(__name__)


def get_bucket_name() -> str:
    bucket = get_settings().S3_ASSETS_BUCKET
    logger.info(f"Using bucket name={bucket}")
    return bucket


s3 = None


def get_s3_client():
    global s3
    if s3 is None:
        settings = get_settings()
        s3 = boto3.client(
            "s3",
            endpoint_url=f"http://{settings.MINIO_ENDPOINT}",
            aws_access_key_id=settings.MINIO_ACCESS_KEY,  # type: ignore
            aws_secret_access_key=settings.MINIO_SECRET_ACCESS_KEY,  # type: ignore
            region_name=settings.AWS_REGION,  # type: ignore
        )
    return s3


def generate_presigned_url(key: str, expires_in: int = 600) -> str:
    """
    Generate a pre-signed S3 URL for the given key.
    expires_in: time in seconds before URL expires
    """
    return get_s3_client().generate_presigned_url(
        ClientMethod="get_object",
        Params={"Bucket": get_bucket_name(), "Key": key},
        ExpiresIn=expires_in,
    )


def upload_to_s3(file: Any, key: str, bucket: str = get_bucket_name()):
    try:
        logger.info("Checking if bucket exists")
        get_s3_client().head_bucket(Bucket=bucket)
    except ClientError:
        logger.info("Bucket does not exist yet, creating")
        get_s3_client().create_bucket(Bucket=bucket)

    logger.info(f"Sending file to bucket={bucket}, key={key}")
    get_s3_client().upload_fileobj(file, bucket, key)
