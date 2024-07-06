# Create a DynamoDB table.
resource "aws_dynamodb_table" "user_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"

  attribute {
    name = "username"
    type = "S"
  }
  attribute {
    name = "date_of_birth"
    type = "S"
  }

  # Define the Global Secondary Index
  global_secondary_index {
    name            = "date_of_birth_index"
    hash_key        = "date_of_birth"
    projection_type = "ALL"
  }
}



#DynamoDB Endpoint
resource "aws_vpc_endpoint" "dynamodb_Endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}