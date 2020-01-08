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

8) Hit ```install app from file``` while inside of Splunk and install the provided tar file. 

9) Enable self signed cert for the Splunk server so it can connect to the Amazon API.

9) Let's go into the AWS console and configure our CloudTrail to pipe new event notifications into an SNS queue and we'll name it ```bsides-topic```

9) Edit the access policy on your SNS topic to include the following statement:
```{
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

10) Let's configure our S3 bucket to send to an SQS queue 

9) Now we'll need to configure ingestion to Splunk from CloudTrail, we'll need to create an IAM user that has 
