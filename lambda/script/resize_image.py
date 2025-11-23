import io
import os

import boto3
from PIL import Image  # noqa

s3 = boto3.client("s3")
bucket_name = os.environ["BUCKET_NAME"]


def lambda_handler(event, context):
    print(f"Using the following bucket name={bucket_name}")
    for record in event["Records"]:
        key = record["s3"]["object"]["key"]

        response = s3.get_object(Bucket=bucket_name, Key=key)

        print(f"File downloaded from {bucket_name}/{key}. Performing picture resizing")
        img = Image.open(response["Body"])

        img = img.resize((256, 256))

        buffer = io.BytesIO()
        img.save(buffer, format="PNG")
        buffer.seek(0)

        s3.put_object(Bucket=bucket_name, Key=key, Body=buffer, ContentType="image/jpeg")
        print("Overwritten the original picture with a resized one")

    return {"status": "success"}
