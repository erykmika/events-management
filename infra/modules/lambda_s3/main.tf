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

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.review_assets.bucket
    }
  }

  role = var.iam_role_arn
}


resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_images.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.review_assets.arn
}


resource "aws_s3_bucket_notification" "uploads_notification" {
  bucket = aws_s3_bucket.review_assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_images.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_function.process_images,
    aws_lambda_permission.allow_s3_invoke
  ]
}
