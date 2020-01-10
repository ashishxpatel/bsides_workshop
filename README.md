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

## Initial Infrastructure with Terraform (Splunk Server, Automation Server, CloudTrail)

1) Clone this repo to download all course materials:

```bash
$ git clone https://github.com/ashishpatel-git/bsides_workshop.git
```

```bash
$ cd bsides_workshop
```

FIXME: maybe change the name of this repo to be the same-ish as the workshop title.

2) Install Terraform & the AWS CLI 
https://learn.hashicorp.com/terraform/getting-started/install.html.

On MacOS:
```bash
$ curl -O https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_darwin_amd64.zip
$ unzip terraform_0.12.19_darwin_amd64.zip
$ rm terraform_0.12.19_darwin_amd64.zip
$ export PATH=$PATH:`pwd`

```

On MacOS:
```bash
$ pip3 --version
$ curl -O https://bootstrap.pypa.io/get-pip.py
$ python3 get-pip.py --user
$ pip3 install awscli --upgrade --user
```

FIXME: Once details are ironed out, we can go through these steps and take screenshots

3) Create an IAM admin user called "terraform" with the "Administrator" policy attached.

4) Use the AWS secrets to input them into your local AWS CLI configuration for TF to use.

5) Run ```terraform init``` to initialize your TF directory. Once that is completed, you can run a ```terraform plan``` commmand to see what all the potential infrastructure will look like.

6) Once everything checks out we can then run a ```terraform apply``` to configure our resources inside of AWS.

7) Now we'll have our Splunk server and CloudTrail created with the appropriate S3 bucket. Next we'll want to install the AWS add on inside of Splunk so we can easily configure our CloudTrail ingestion.

## Splunk Configuration

1) Hit ```install app from file``` while inside of Splunk and install the provided tar file.

2) Enable self signed cert for the Splunk server so it can connect to the Amazon API.

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
      "Resource": "arn:aws:sns:us-west-2:<your_account_id>:bsides-topic",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:::bsides-trail"
        }
      }
    }
```

5) Now we'll create 2 different SQS queues for Splunk, one deadletter queue and a normal one. Follow the default configurations and create one queue called ```bsides-queue``` and one named ```bsides-deadletter```. Once this is completed, you can configure the ```bsides-queue``` to have the deadletter queue be the other one. Enable redrive policy on this queue and add in 500 for the field for maximum retries. On this main queue, we will copy the ARN from our SNS topic and add it to the allowed permissions, so that SNS can push to the queue. Finally we will subscribe this SQS queue to our bsides SNS topic. Once this is all set and done you should now slowly begin to see CloudTrail log events coming in through Splunk.

## Searching and Alerting with Splunk
FIXME
1) Look at CloudTrail logs in Splunk

2) Walk through creation of an alert that writes to SNS

## Python python python
FIXME

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

## Jira jira jira
FIXME

1) Configure Splunk alert for when the above lambda runs

2) Walk through creating tickets from SNS (local or on EC2):
```python
import boto3
import jira

def create_jira_issue(alert_name, alert_body):
    j = jira.JIRA(
        settings.jira_url,
        basic_auth=(settings.username, settings.password),
    )
    j.create_issue(
        project=settings.jira_project,
        summary="SplunkAlert: {}".format(alert_name),
        description=json.dumps(alert_body),
        issuetype="Alert",
    )

while 1:
    # FIXME: Consume from SNS queue
    if SNS_event:
      create_jira_issue("fixme", "fixme")
```

3) Put ^^^ into a Lambda

## Lambda configuration 2 (Insert Unicorn Emoji Here :D )

1) Take a look at the two pieces of code we have inside of this repo. ```aws_autofix_securitygroups.py``` and ```auto_disable_api.py```. In this example we'll be utilizing ```auto_disable_api.py``` which will shut down any access that is outside of operating region from an access key that was used. We'll be detecting this using IPlocation within Splunk and passing information to our Lambda via SNS to disable the access key in question.

2) We'll need to start by heading to the Lambda console and creating a new Lambda in Python 3. A role should be created for this Lambda called ```IAMRemediationRole``` in the IAM console. We'll attach two different policies, one custom one for IAM actions:

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


