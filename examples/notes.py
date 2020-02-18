import boto3
sns = boto3.client("sqs")

print("== SQS Queues ==")
print(sqs.list_queues())

s3 = boto3.client('s3')
print("== S3 Buckets ==")
print(s3.list_buckets())

