output "ip" {
  description = "public IP of the ec2 instance"
  value = aws_instance.name.public_ip
  sensitive = true
}

output "bucket_arn" {
  description = "arn of s3 bucket"
  value = aws_s3_bucket.name.arn
}

