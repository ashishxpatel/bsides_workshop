## Configure CloudTrail logging and notifications
3) Let's go into the AWS console and configure our CloudTrail to pipe new event notifications into an SNS queue and we'll name it ```bsides-topic```.

4) Edit the access policy on your SNS topic to include the following statement:
```
    {
      "Sid": "publish-from-s3",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:us-west-2:$YOUR_ACCOUNT_ID:bsides-topic",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:::bsides-trail"
        }
      }
    }
```
* FIXME: Need to add a lot of explanation about where/how to do this. Expect tons of problems with JSON formatting and adding a comma in the right place. Could we just do it with Python instead?

5) Now we'll create 2 different SQS queues for Splunk, one deadletter queue and a normal one. Follow the default configurations and create one queue called ```bsides-queue``` and one named ```bsides-deadletter```. Once this is completed, you can configure the ```bsides-queue``` to have the deadletter queue be the other one. Enable redrive policy on this queue and add in 500 for the field for maximum retries. On this main queue, we will copy the ARN from our SNS topic and add it to the allowed permissions, so that SNS can push to the queue. Finally we will subscribe this SQS queue to our bsides SNS topic. Once this is all set and done you should now slowly begin to see CloudTrail log events coming in through Splunk.

* FIXME: Need to break this out into steps with screenshots. It's a _lot_ for a single step.
* FIXME: Could we just do this with Python?

## CloudTrail? SNS? SQS? Looking under the hood with Python
Let's take a look under the hood at what's happening with our logs. First we'll take a look at what queues we have available and print the URL of the `bsides-queue` queue.

```python
import json
import boto3

sqs = boto3.client('sqs')
queues = sqs.list_queues()
print(queues)

# Output will be something like:
# {'QueueUrls': ['https://us-west-2.queue.amazonaws.com/ACCOUNT_ID/bsides-deadletter',
#   'https://us-west-2.queue.amazonaws.com/ACCOUNT_ID/bsides-queue'],
#  'ResponseMetadata': {'RequestId': '78e1edc5-beb1-5667-b6c6-bb514fd2de26',
#   'HTTPStatusCode': 200,
#   'HTTPHeaders': {'x-amzn-requestid': '78e1edc5-beb1-5667-b6c6-bb514fd2de26',
#    'date': 'Sun, 12 Jan 2020 10:04:19 GMT',
#    'content-type': 'text/xml',
#    'content-length': '419'},
#   'RetryAttempts': 0}}

queue_url = [q for q in queues['QueueUrls'] if q.endswith('bsides-queue')][0]
print(queue_url)

# Output:
# https://us-west-2.queue.amazonaws.com/ACCOUNT_ID/bsides-queue
```

Next, let's pull a message from the queue and see what it looks like.

```python
message = sqs.receive_message(QueueUrl=queue_url)
# Output will be something like:
# {'Messages': [{'MessageId': '7de4a3d9-2868-4ece-aeb3-a1460eefb6b3',
#    'ReceiptHandle': 'AQEBCfZqk25k+7eRX8VM3yRQyEcu0s5zSv2VcI853B6uYJebyg+K8m7HqrhnRZD6syQlYFc7z7cDAh6f6sJ3u+lcTSK3lLdkzaLeUDwdQHgItr0KPy1dNQGkH/WK/Dt/0BANXCvFiyzvOMvTkl9JiYhEzYH9FRbGwW63xUiEsNxYKIr1h73iZ8KCdWpPElGWrY7/l27KOrj4nM0eWWLCEEIInGoG3JEX89X0QCI5AA4YCx/c1yWDx/a/qLYge5DFmTe2WEEDGj3j91x/aQATRC7cunaKKmUp1lviuq0HBexQFvneH36CHq+7a6WSoreHb8CGDpvD3sa8+bLn3Ng6EwORL+ZMh1lQ7aF3YzHUcC8kkm3QHjpv92INlw20ZsrUCMeIrD/wJibluv30Ptc5VUtUlw==',
#    'MD5OfBody': 'c5b1d12d4bf4913856579c8c29a41df2',
#    'Body': '{\n  "Type" : "Notification",\n  "MessageId" : "d4ef62a2-b761-565f-ac03-34365d35d874",\n  "TopicArn" : "arn:aws:sns:us-west-2:ACCOUNT_ID:bsides-topic",\n  "Message" : "{\\"s3Bucket\\":\\"bsides-trail-20200112083857693900000001\\",\\"s3ObjectKey\\":[\\"prefix/AWSLogs/ACCOUNT_ID/CloudTrail/us-west-2/2020/01/12/ACCOUNT_ID_CloudTrail_us-west-2_20200112T0930Z_XNcKI5JFGkzUeu0m.json.gz\\"]}",\n  "Timestamp" : "2020-01-12T09:34:12.116Z",\n  "SignatureVersion" : "1",\n  "Signature" : "Smtdm5Cai/ortbXR7wk1Vv4kwy3RlTelAH2UO4cLx1/tKukQEA/fqyLASZ7A3VkZlJVbSyDJ5n93hBHvY8+mXt5ip39r6O14D3iz7zh5SFUHXJgX8Csr1W9azJTfoiefbquH3bhyceLwQxrnw/FBi1LXkFgDNDsZj753QM0M192TQ1JTxNu2hoph5G++pIRXVVrg7pTYV8xxzJV4C/NvCK0vUnq3BnAnbSHVgWx7IIVlY3i9vmzI7wd7mpc2rDNiJPNHMdaUczCZU31u8WyGasA6EicyhvizUz6AxHfykNcNRPnz/QnBCk+8tnltAf7uF1LlI1ICrwIzbRkQ0gRHcg==",\n  "SigningCertURL" : "https://sns.us-west-2.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem",\n  "UnsubscribeURL" : "https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:ACCOUNT_ID:bsides-topic:c7d39b72-b232-4e5b-8bde-a8a0469c0413"\n}'}],
#  'ResponseMetadata': {'RequestId': '7daac050-2003-543d-b2ea-96c4d2101de6',
#   'HTTPStatusCode': 200,
#   'HTTPHeaders': {'x-amzn-requestid': '7daac050-2003-543d-b2ea-96c4d2101de6',
#    'date': 'Sun, 12 Jan 2020 10:07:15 GMT',
#    'content-type': 'text/xml',
#    'content-length': '2198'},
#   'RetryAttempts': 0}}
```

Wow, that is pretty terrible. If we dig in a little bit, it looks like the message body is still raw JSON. Let's pull it out:

```python
message_body = json.loads(message['Messages'][0]['Body'])

message_body['Message']
print(message_body)

# {'Type': 'Notification',
#  'MessageId': 'd4ef62a2-b761-565f-ac03-34365d35d874',
#  'TopicArn': 'arn:aws:sns:us-west-2:ACCOUNT_ID:bsides-topic',
#  'Message': '{"s3Bucket":"bsides-trail-20200112083857693900000001","s3ObjectKey":["prefix/AWSLogs/ACCOUNT_ID/CloudTrail/us-west-2/2020/01/12/ACCOUNT_ID_CloudTrail_us-west-2_20200112T0930Z_XNcKI5JFGkzUeu0m.json.gz"]}',
#  'Timestamp': '2020-01-12T09:34:12.116Z',
#  'SignatureVersion': '1',
#  'Signature': 'Smtdm5Cai/ortbXR7wk1Vv4kwy3RlTelAH2UO4cLx1/tKukQEA/fqyLASZ7A3VkZlJVbSyDJ5n93hBHvY8+mXt5ip39r6O14D3iz7zh5SFUHXJgX8Csr1W9azJTfoiefbquH3bhyceLwQxrnw/FBi1LXkFgDNDsZj753QM0M192TQ1JTxNu2hoph5G++pIRXVVrg7pTYV8xxzJV4C/NvCK0vUnq3BnAnbSHVgWx7IIVlY3i9vmzI7wd7mpc2rDNiJPNHMdaUczCZU31u8WyGasA6EicyhvizUz6AxHfykNcNRPnz/QnBCk+8tnltAf7uF1LlI1ICrwIzbRkQ0gRHcg==',
#  'SigningCertURL': 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem',
#  'UnsubscribeURL': 'https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:ACCOUNT_ID:bsides-topic:c7d39b72-b232-4e5b-8bde-a8a0469c0413'}
```

That's looking better, but the `Message` field seems to be more JSON buried inside that JSON! Let's parse it out:
```python
message_body_message = json.loads(message_body['Message'])

# {'s3Bucket': 'bsides-trail-20200112083857693900000001',
#  's3ObjectKey': ['prefix/AWSLogs/ACCOUNT_ID/CloudTrail/us-west-2/2020/01/12/ACCOUNT_ID_CloudTrail_us-west-2_20200112T0930Z_XNcKI5JFGkzUeu0m.json.gz']}
```

Now we've got something useful. SNS is essentially providing information about where files are being written to in our S3 bucket. Let's grab that file and see what's in it:

```python
s3 = boto3.client("s3")
s3_bucket = message_body_message['s3Bucket']
s3_object_key = message_body_message['s3ObjectKey'][0]
s3.download_file(s3_bucket, s3_object_key, 'logs.json.gz')
```

This will download a file named `logs.json.gz` to our local directory. Unzip it with `gunzip logs.json.gz` and you can see the raw log events. These are the same as what will be ingested in Splunk.
