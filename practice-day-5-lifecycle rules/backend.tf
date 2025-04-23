terraform {
  backend "s3" {
    bucket         = "meyyannew123"               # Name of the S3 bucket where the state file will be stored
    region         = "us-east-1"                     # AWS region
    key            = "terraform.tfstate"             # Path within the bucket where the state file will be stored
    dynamodb_table = "lock-dynamo"   # DynamoDB table used for state locking
    encrypt        = true                             # Ensures the state is encrypted at rest in S3
  }
}