output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = aws_s3_bucket.review_assets.bucket
}