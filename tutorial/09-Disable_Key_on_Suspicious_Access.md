# Disabling API Keys

This section needs more development. For now, we are leaving it as an exercise for the reader.


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
