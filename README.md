# bsides_workshop
Instructions on how to deploy cloud infrastructure for the BSides 2020 SF workshop demo:

## Initial Infrastructure with Terraform (Splunk Server, Automation Server, CloudTrail)

1) Install Terraform on your local CLI - https://learn.hashicorp.com/terraform/getting-started/install.html. 

2) Download and copy the provided TF files found in this repo.

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


