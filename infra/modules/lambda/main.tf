resource "aws_lambda_layer_version" "python_libs" {
  layer_name  = "${var.project}-python-libs"
  filename    = "${path.root}/../lambda/layer/layer.zip"

  compatible_runtimes = ["python3.14"]
  compatible_architectures = ["x86_64"]

  source_code_hash = filebase64sha256("${path.root}/../lambda/layer/layer.zip")
}

resource "aws_lambda_function" "process_images" {
  function_name = "${var.project}-process-images"
  handler       = "resize_image.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  timeout = 10
  memory_size = 512

  filename         = "${path.root}/../lambda/script/lambda.zip"
  source_code_hash = filebase64sha256("${path.root}/../lambda/script/lambda.zip")

  layers = [aws_lambda_layer_version.python_libs.arn]

  role = var.iam_role_arn

  environment {
    variables = {
      BUCKET_NAME          = var.s3_assets_bucket
      MINIO_ENDPOINT       = var.minio_endpoint
      MINIO_ACCESS_KEY     = var.minio_access_key
      MINIO_SECRET_KEY     = var.minio_secret_access_key
    }
  }
}