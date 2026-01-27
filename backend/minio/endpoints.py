from fastapi import APIRouter
from starlette.requests import Request

router = APIRouter(prefix="/minio", tags=["minio"])


@router.post("/webhook")
async def minio_webhook(request: Request):
    """Accept MinIO notification JSON and process the uploaded image by resizing it.

    Example MinIO notification body:
    {
      "Records": [
        { "s3": { "bucket": {"name": "bucket"}, "object": {"key": "path/to/object.jpg"} } }
      ]
    }
    """
    payload = await request.body()

    print(f"payload: {payload}")

    # try:
    #     data = json.loads(payload)
    # except Exception as exc:
    #     raise HTTPException(status_code=400, detail=f"invalid json: {exc}")
    #
    # for record in data.get("Records", []):
    #     bucket = record["s3"]["bucket"]["name"]
    #     key = record["s3"]["object"]["key"]
    #
    #     try:
    #         response = s3.get_object(Bucket=bucket, Key=key)
    #         img = Image.open(response["Body"])
    #         img = img.resize((256, 256))
    #
    #         buffer = io.BytesIO()
    #         img.save(buffer, format="PNG")
    #         buffer.seek(0)
    #
    #         s3.put_object(Bucket=bucket, Key=key, Body=buffer, ContentType="image/png")
    #     except Exception as exc:
    #         raise HTTPException(
    #             status_code=500, detail=f"Error processing image {key}: {str(exc)}"
    #         )

    return {"status": "processed"}
