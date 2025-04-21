resource "aws_s3_bucket" "example" {
  bucket = "meyyannew123"  # Change this bucket name to a unique name
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "lock-dynamo"
  hash_key       = "LockID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}