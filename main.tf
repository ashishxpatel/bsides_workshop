# Create our server infrastructure needed

resource "aws_instance" "splunk-server" {
  ami           = "ami-047942f791d04b69f"
  instance_type = "t2.medium"
  security_groups = ["${aws_security_group.splunk_allow.name}"]
  iam_instance_profile = aws_iam_instance_profile.splunk_profile.name
  tags = {
    Name = "splunk-server"
  }
}
resource "aws_security_group" "splunk_allow" {
  name = "allow_splunk_ports_ingress"
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 554
    to_port     = 554
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 997
    to_port     = 997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "automation-server" {
  ami           = "ami-06d51e91cea0dac8d"
  instance_type = "t2.small"
  security_groups = ["${aws_security_group.automation_allow.name}"]
  tags = {
    Name = "automation-server"
  }
}
resource "aws_security_group" "automation_allow" {
  name = "allow_automation_ports_ingress"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "splunk_role" {
  name = "splunk_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "splunk_policy" {
  name = "splunk_policy"
  role = aws_iam_role.splunk_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*",
        "sqs:*",
        "sns:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "splunk_profile" {
  name = "splunk_profile"
  role = aws_iam_role.splunk_role.name
}

# Configure our CloudTrail

data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "bsides_trail" {
  name                          = "bsides-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
  is_multi_region_trail = true
  sns_topic_name = aws_sns_topic.aws_cloudtrail_sns.name
  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket_prefix = "bsides-trail-"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrail_logs.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrail_logs.arn}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

# Create our Lambda policies (one for EC2 remediation)

resource "aws_iam_role_policy" "iam_remediation_policy" {
  name = "iam_remediation_policy"
  role = aws_iam_role.iam_remediation_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:UpdateAccessKey",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:DescribeInstances",
                "ec2:DescribeSecurityGroupReferences",
                "ec2:DescribeRegions",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeStaleSecurityGroups",
                "sns:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "iam_remediation_role" {
  name = "iam_remediation_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Configure SNS and SQS for our automation and CloudTrail ingestion

resource "aws_sns_topic_policy" "splunk-sns-topic-policy" {
  arn = aws_sns_topic.aws_cloudtrail_sns.arn
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailSNSPolicy20131101",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "SNS:Publish",
            "Resource": "${aws_sns_topic.aws_cloudtrail_sns.arn}"
        }
    ]
}
EOF
}

resource "aws_sns_topic" "aws_cloudtrail_sns" {
  name = "aws_cloudtrail_sns"
}

resource "aws_sns_topic" "aws_lambda_sns" {
  name = "aws_lambda_sns"
}

resource "aws_sqs_queue" "aws_splunk_queue_deadletter" {
  name                      = "aws_splunk_queue_deadletter"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  visibility_timeout_seconds = 900
}

resource "aws_sqs_queue" "aws_splunk_main_queue" {
  name                      = "aws_splunk_main_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  visibility_timeout_seconds = 900
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.aws_splunk_queue_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue_policy" "aws_splunk_main_queue" {
  queue_url = aws_sqs_queue.aws_splunk_main_queue.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.aws_splunk_main_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.aws_cloudtrail_sns.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "cloudtrail_updates_sqs_target" {
  topic_arn = aws_sns_topic.aws_cloudtrail_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.aws_splunk_main_queue.arn
}

## Create the terraform lamdbas (1 for IAM remediation, 2 for EC2 remediation)

data "archive_file" "automation_lambda_zip" {
    type        = "zip"
    source_dir  = "automation_lambda/"
    output_path = "automation_lambda.zip"
}

resource "aws_lambda_function" "automation_lambda" {
  filename = "automation_lambda.zip"
  source_code_hash = data.archive_file.automation_lambda_zip.output_base64sha256
  function_name = "automation_lambda"
  role = aws_iam_role.iam_remediation_role.arn
  description = "automation lambda"
  handler = "automation_lambda.lambda_handler"
  runtime = "python3.6"
  timeout = 90
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.automation_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.aws_lambda_sns.arn
}

resource "aws_sns_topic_subscription" "sns_trigger_lambda" {
  topic_arn = aws_sns_topic.aws_lambda_sns.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.automation_lambda.arn
}

