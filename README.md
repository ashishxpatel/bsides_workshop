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
