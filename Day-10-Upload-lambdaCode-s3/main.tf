provider "aws" {
  region = "us-west-1"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "MyS3Lambda"

  role    = aws_iam_role.lambda_exec_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"

  s3_bucket = "newbucketmeyyan"   
  s3_key    = "lambda_code/lambda_function.zip"
  
  environment {
    variables = {
      ENV = "prod"
    }
  }
}