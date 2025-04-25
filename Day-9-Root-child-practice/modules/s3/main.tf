resource "aws_s3_bucket" "s3California" {
  bucket = var.bucket_name

  tags = {
    Name = "ModularS3"
  }
}