# If This Then Hack: An Intro to DIY Cloud Security Automation with Python

Security engineers face the daily task of detection, responding, and remediating incidents in both cloud and on-premise environments. Recent high-profile breaches have highlighted that even the organizations we would expect to have fine-tuned and automated security programs often have critical blind spots. Automating your incident response and detection workflows into existing pipelines can save time and manual analyst efforts which result in faster resolution times. There are any number of vendor that will happily take your money, but we can start to build our own DIY alternative with just some artisanal Python and the tools we already have.

Our workshop will discuss the core principles of what it takes to build your own automation tools for cloud security, from detecting events to automatically remediating. We won't be using toy examples: we'll be using the security tools we have used in industry like Splunk and Jira to build realistic end-to-end automation workflows. Students in our workshop will learn how to integrate the following flow 1) Identify an event (in public cloud), 2) Produce and capture the details of the event in Splunk and create a ticket in Jira, 3) Automatically enrich this data and create the appropriate automated remediation response. These steps can be completed to eliminate manual overhead on detection in the cloud as well as proper delegation to the appropriate team (incident response team, compliance, engineering teams, or other). With the use of simple Python scripts students will learn how they can build a simple yet fundamental security automation system. 

The approach to building automation you will learn in this workshop is applicable to any kind of ticket-centric operations environment, not just security. We want to pull back on the curtain on "security automation" and show that it really isn't magic, it's just a bit of code in the right places.

# Requirements
Students should be comfortable with basic Python scripting (at a minimum, able to write functions, loops, and conditionals without consulting documentation) and should be familiar with security terminology. The student who stands to gain the most from this course is one with professional experience in security and an interest in developing new skills in applying programming to automate their work.

# Text Dump From Initial Submission, to be moved around

## Introduction to public cloud security risks and common security scenarios (Workshop Presentation)
* We will discuss the numerous security events occurring in the public cloud space particularly in AWS where security engineers have to be vigilant
  * Specific examples: public S3 buckets & open security groups
* Next, we will dive into the types of log sources that can be evaluated from a public cloud account in AWS and the details of what we'd want to capture
  * What are the types of log sources?
  * CloudTrail (API)
  * NetFlow (VPC activity)
  * DNS logs (Route53)
* Review common security events and what they look like in CloudTrail
  * Modification of CloudTrail for example
  * EC2 changes, IAM API calls

## Introduction to security automation and the core pieces involved (Workshop Presentation)
* Now we can find events: how do we react to them?
* What automation tool stack will we be using and the benefits of each
  * We'll be using the tools that we actually do use - while not a perfect match for everyone's environments, these are the major components that almost every company works with
  * This is not the easiest way. It's not the simplest. But it reflects real-world patterns that apply to many many scenarios. Logging and compliance matter
  * Jira
    * Documented evidence of a security incident or event
    * Ability to tag to the responding team that is on call
    * Ability to enrich the ticket with details that enhance the overall mean time to resolution (Tagging to service owners etc..)
  * Splunk
    * Ability to collect and store log data from all sources (CloudTrail retention)
    * Pipeline to automate detections and alerting into the right destinations
    * Flow through to Jira, Slack with updated enriched data through the use of lookup tables etc..
  * Slack
    * Instant notification to teams regarding incidents
    * Prioritization of security incidents 
    * Ability to build out slack bots that can do some work for you
* Code review of flows
  * Jira API overview
  * Splunk Python automation overview
  * Slack webhook Python demonstration

## Detect and respond to a security event in the public cloud using automation (Workshop Exercises)
* Set up CloudTrail logging into Splunk
  * Basic add on for the ingestion of S3 CloudTrail logs
* See event ingested in Splunk
  * Verify that we have CloudTrail JSON events coming through
* Create and set up our automation flow to respond to incidents
  * We develop a Splunk query for an alert
  * We create a Splunk saved search: run that query every N minutes, trigger a webhook action when an alert condition is satisfied
  * We write our automation server to receive that webhook and create a ticket 
  * We configure webhooks in Jira to call back to the automation server on ticket creation
  * We add a new to the automation server to receive those webhooks, run lookups/enrichments, take actions (AWS account ID lookup, disable key)
* Build automation workflows to react to these "malicious" actions:
  * An AWS security malicious event occurs, someone has disabled your CloudTrail 
  * API Usage from unauthorized IP outside of your organization
* Validate our automation flow worked and confirm tickets & actions were completed


# Cloud Infrastructure Setup
Instructions on how to deploy cloud infrastructure.

## Local Development Setup

#### Clone this repo to download all course materials:

```bash
git clone https://github.com/ashishpatel-git/bsides_workshop.git
cd bsides_workshop
```

FIXME: maybe change the name of this repo to be the same-ish as the workshop title.

#### Install Terraform

MacOS/Linux Quickstart:
```bash
curl -O https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_darwin_amd64.zip
unzip terraform_0.12.19_darwin_amd64.zip
rm terraform_0.12.19_darwin_amd64.zip
export PATH=$PATH:`pwd`
terraform --version # verify installation
```

More information: https://learn.hashicorp.com/terraform/getting-started/install.html

#### Install AWS CLI and Python development environment

```bash
python3 -m venv venv
source venv/bin/activate
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
pip3 install awscli boto3 jira
aws --version
python3 -c "import boto3; print(boto3.__version__)"
python3 -c "import jira; print(jira.__version__)"
```

More information (AWS): https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#install-bundle-macos

More information (virtualenvironment): https://docs.python.org/3/library/venv.html

#### Subscribe Splunk Enterprise in AWS Marketplace
We will be using the Splunk Enterprise AMI from the AWS Marketplace, which requires subscribing before we can use it. Visit https://aws.amazon.com/marketplace/pp?sku=7azvchdfh74dcxoiwjhztgpel, click `Continue to Subscribe`, and accept the terms.

This does _not_ cost anything and does not provide a Splunk license, it only allows us to use the AMI (which does come with a baked-in trial license that we will be using).

#### Other options and platforms
You can install AWS CLI, Terraform, and pip with your package manager of choice (brew, yum, apt-get, etc.). Using a Python virtualenvironment is not strictly required, but we do strongly suggest that you use a venv and install dependencies in it with pip.

FIXME: Once details are ironed out, we can go through these steps and take screenshots

## Infrastructure with Terraform (Splunk Server, Automation Server, CloudTrail)

#### Log in to your AWS account
https://console.aws.amazon.com/iam

#### Create Terraform user
Navigate to `Access management` -> `Users` -> `Add user` and create a user named `terraform` with `Programmatic access`.

![Adduser](images/adduser1.jpg?raw=true "Add user")

Attach the AdministratorAccess policy

![Adduser](images/adduser2.jpg?raw=true "Add user")

Proceed through the "Add tags" page, review your configuration, and create the user. _Download or otherwise save the account credentials now, as they will not be available again._

#### Add AWS credentials
Run `aws configure` and input your access key ID and secret. This will save your credentials to a config file at `~/.aws/credentials`.

```
$ aws configure
AWS Access Key ID [None]: KEYGOESHERE
AWS Secret Access Key [None]: SECRETGOESHERE
Default region name [None]: us-west-2
Default output format [None]:
```

Note that we are using the `us-west-2` AWS region as it is geographically nearby and typically one of the least expensive.

#### Create Infrastructure with Terraform
Initialize your Terraform directory:
```
terraform init
```

See what Terraform is going to do:
```
terraform plan
```

Check that the plan looks good, then apply the plan to create these resources in AWS:

```
terraform apply
```

Now we'll have our Splunk server and CloudTrail created with the appropriate S3 bucket.

When we're done with this infrastructure, we will take it all down with:

```
# Don't run this yet!
terraform destroy
```

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

## Splunk Configuration
To log in to your Splunk server, find the instance in the AWS EC2 Dashboard and find the Public IP or Public DNS entry for your server. Open a web browser and go to `http://YOUR_IP_OR_DNS:8000/`.

Log in with username `admin` and password `SPLUNK-$INSTANCE_ID` (copy your instance ID from the EC2 dashboard).

1) Install Splunk App for AWS

* FIXME: Add instructions to create Splunk account and download file
* FIXME: Update with step-by-step instructions / screenshots
* FIXME: It'll probably be easiest to install with the `Install` button so we don't have to download then re-upload the file.

Next we'll want to install the Splunk App for AWS (FIXME: Splunk Add-on for Amazon Web Services?) inside of Splunk so we can easily configure our CloudTrail ingestion.

1) Hit ```install app from file``` while inside of Splunk and install the provided tar file.

2) Enable self signed cert for the Splunk server so it can connect to the Amazon API.
* FIXME: What does this mean?


## Searching and Alerting with Splunk
1) Look at CloudTrail logs in Splunk

2) Walk through creation of an alert that writes to SQS




Start with small Python snippets that will be expanded

1) Local on laptop or in a Linux EC2 install boto and start exploring with either small script or interactive terminal.

2) View events in SNS queue (see the output from that Splunk alert)

3) View and change security groups

## Lambda configuration 1 (Insert Unicorn Emoji Here :D )

1) Take a look at the two pieces of code we have inside of this repo. ```aws_autofix_securitygroups.py``` and ```auto_disable_api.py```. These two pieces of python will be the demo detections we will roll out into our automated environment to help us watch and remediate for EC2 security group exposures to the public facing web and also API usage from regions or IP spaces we do not operate from.

2) Let's start with the first Lambda for detecting bad security groups and remediating them on the spot. We'll need to start by heading to the Lambda console and creating a new Lambda in Python 3. A role should be created for this Lambda called ```EC2RemediationRole``` in the IAM console. We'll attach two different policies, one custom one for EC2 actions:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeSecurityGroupReferences",
                "ec2:DescribeRegions",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeStaleSecurityGroups"
            ],
            "Resource": "*"
        }
    ]
}
```

In addition, we'll also attach the AWS managed policy ```AWSLambdaBasicExecutionRole``` which should give us the ability to write to CloudWatch logs and also execute our Lambda code. Once this is completed, we should select this role ```EC2RemediationRole``` for our Lambda to use. Copy and paste in the Python 3 code. Now we'll need a trigger to execute this Lambda, since we want to monitor every 2 minutes we can configure a CloudWatch based cron trigger that will run. In the expression field we can enter ```rate(2 minute)```.

3) Now that our Lambda is in place, we can attach a security test security group called ```malicious_sg``` with permissions of port ```3389``` ingress open to the world. Note: whitelisted ports can be modified within the python code itself, there are many ways of going about this but this is one example :). We should now wait a few minutes and we'll notice that the bad SG has been removed from our automation server.

## Working with the Jira API
Working with Jira through the Python SDK is pretty straightforward. We should have already installed it above with `pip install jira`. Check the full SDK documentation at: https://jira.readthedocs.io/en/master/

### Keep secrets separate
Secrets management is hard. But for our simple usecase, we can put our secrets in a separate Python file and import it into our other files. This way we can keep all of our code in a git repo without exposing secrest.

```python
""" settings.py """
jira_url = "$URL"
jira_username = "$USERNAME"
jira_password = "$PASSWORD"
```

### Creating an issue



1) Configure Splunk alert for when the above lambda runs

2) Walk through creating tickets from SNS (local or on EC2):


```python
import jira

j = jira.JIRA(
    settings.jira_url,
    basic_auth=(settings.jira_username, settings.jira_password),
)
```

```
In [14]: j.projects()
Out[14]: [<JIRA Project: key='MOS', name='MosesProject1', id='10000'>]
```

```python
issue = j.create_issue(
    project=settings.jira_project,
    summary="Hello, world!",
    description="Insert description here",
    issuetype="Task",
)

print(issue)
print(issue.fields.summary)
print(issue.fields.comment.comments)
```

```
In [10]: i.fields.comment.comments
Out[10]: []

In [22]: j.add_comment("MOS-1", "Hello, comment!")
Out[22]: <JIRA Comment: id='10000'>

In [25]: i.update()

In [26]: i.fields.comment.comments
Out[26]: [<JIRA Comment: id='10000'>, <JIRA Comment: id='10001'>]
```

while 1:
    # FIXME: Consume from SNS queue
    if SNS_event:
      create_jira_issue("fixme", "fixme")
```

3) Put ^^^ into a Lambda

## Lambda configuration 2 (Insert Unicorn Emoji Here :D )

1) Take a look at the two pieces of code we have inside of this repo. ```aws_autofix_securitygroups.py``` and ```auto_disable_api.py```. In this example we'll be utilizing ```auto_disable_api.py``` which will shut down any access that is outside of operating region from an access key that was used. We'll be detecting this using IPlocation within Splunk and passing information to our Lambda via SNS to disable the access key in question.

2) We'll need to start by heading to the Lambda console and creating a new Lambda in Python 3. A role should be created for this Lambda called ```IAMRemediationRole``` in the IAM console. We'll attach two different policies, one custom one for IAM actions:
+15055061890
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:UpdateAccessKey"
            ],
            "Resource": "*"
        }
    ]
}
```

In addition, we'll also attach the AWS managed policy ```AWSLambdaBasicExecutionRole``` which should give us the ability to write to CloudWatch logs and also execute our Lambda code. Once this is completed, we should select this role ```EC2RemediationRole``` for our Lambda to use. Copy and paste in the Python 3 code. Now we'll need a trigger to execute this Lambda.

3) We can create an SNS topic that will be named ```bsides-sns-iam``` which we'll post to from Splunk when we detect anomalous API activity from our CloudTrail logs.

4) In Splunk we'll configure an alert to look like this in the query field:

```sourcetype = aws:cloudtrail | iplocation sourceIPAddress | search Country != "United States"```

Now we'll add an action for this particular alert to send to an SNS queue. We can add in our Account, Region, and topic name above:

The message field should look like this:

```
$result.userIdentity.accessKeyId$ $result.userIdentity.userName$ $result.Country$
```

This alert will fire when we see API activity coming from a non-US operating IP. This can be altered for your own environment based on which countries you operate out of. The Lambda will need the fields above to disable the access key that is in question.

3) Now that our Lambda is in place, we can spin up an EC2 from an odd region and create a dummy access key with access to EC2 for example. You'll notice that upon attempting to use this key, in the IAM console it will show up as disabled because our automation flow has executed.


