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
