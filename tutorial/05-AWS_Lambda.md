# AWS Lambda Functions
AWS Lambda is a computing platform that allows us to run code in the cloud without needing to set up or manage any servers or containers (hence the phrase "serverless"). Our terraform configuration already created a stub lambda function for us from the code in `automation_lambda/` with an SNS trigger. We'll trigger it from Splunk in the next section, but for now we can just focus on testing the lambda in isolation.

## Testing and Developing Lambda Functions
#### Test this Lambda in AWS
Open the `Lambda` service in the AWS Console, select `Functions` from the sidebar, then follow the link to `automation_lambda` to view the lambda.

This JSON is a simplified version of what we will receive later when Splunk triggers our lambda. For now we don't need to worry about the contents, just add this JSON as our test event data:
```
{
  "Records": [
    {
      "Sns": {
        "Message": "{\"message\": \"create_ticket\", \"timestamp\": \"1581724963\", \"entity\": \"\", \"correlation_id\": \"\", \"source\": \"s3://bsides-trail-20200213222334693500000001/prefix/AWSLogs/583449068983/CloudTrail/us-west-2/2020/02/15/583449068983_CloudTrail_us-west-2_20200215T0005Z_uBoXpDEJKNL2RSqf.json.gz\", \"event\": \"{\\\"eventVersion\\\": \\\"1.05\\\", \\\"userIdentity\\\": {\\\"type\\\": \\\"IAMUser\\\", \\\"principalId\\\": \\\"AIDAYPWCGIW353DNIJEMI\\\", \\\"arn\\\": \\\"arn:aws:iam::583449068983:user/terraform\\\", \\\"accountId\\\": \\\"583449068983\\\", \\\"accessKeyId\\\": \\\"AKIAYPWCGIW3V7JLFK5M\\\", \\\"userName\\\": \\\"terraform\\\"}, \\\"eventTime\\\": \\\"2020-02-15T00:02:43Z\\\", \\\"eventSource\\\": \\\"ec2.amazonaws.com\\\", \\\"eventName\\\": \\\"DescribeInstances\\\", \\\"awsRegion\\\": \\\"us-west-2\\\", \\\"sourceIPAddress\\\": \\\"8.39.49.160\\\", \\\"userAgent\\\": \\\"aws-sdk-go/1.27.0 (go1.13.5; darwin; amd64) APN/1.0 HashiCorp/1.0 Terraform/0.12.19 (+https://www.terraform.io)\\\", \\\"requestParameters\\\": {\\\"instancesSet\\\": {\\\"items\\\": [{\\\"instanceId\\\": \\\"i-07f2402a9ad4877e9\\\"}]}, \\\"filterSet\\\": {}}, \\\"responseElements\\\": null, \\\"requestID\\\": \\\"1bfd5ff9-9624-4018-acf2-0fa467857b79\\\", \\\"eventID\\\": \\\"af663c50-f7f7-4b9a-b038-5e6e6553726c\\\", \\\"eventType\\\": \\\"AwsApiCall\\\", \\\"recipientAccountId\\\": \\\"583449068983\\\"}\", \"search_name\": \"Sample Alert\", \"results_link\": \"http://ip-172-31-7-225:8000/app/search/@go?sid=scheduler__admin__search__RMD57e1d1a7fa4060c79_at_1581725580_1520\", \"app\": \"search\", \"owner\": \"admin\"}"
      }
    }
  ]
}
```

#### Change the Lambda through the Web UI
For simple Lambda functions and initial exploration, you can edit the lambda through the web UI. Try changing the print statement to output "Hello, YourName" instead of "Hello, World" and you'll see the new output when you test the function.

#### Change the Lambda through Terraform
Changing Lambdas through the web UI is useful for simple exploration, but isn't suitable for production use because: 1) All code should be in Git or other version management, and 2) AWS will disable editing in browser when our code gets too large.

To make a change and apply with Terraform, just edit `automation_lambda/automation_lambda.py` to print `Hello, Terraform`, then run
```
./terraform plan
./terraform apply
```

Terraform will then update the lambda with your local copy.

## Create a Ticket with Lambda
Moving our `create_ticket` function from the last section into our lambda will take a few steps.

#### Put secrets into `settings.py`
Copy the `settings.py` you set up in the `tutorial/` directory into `automation_lambda/`.

```
cp tutorial/settings.py automation_lambda/
```

#### Install dependencies
Next we have to install dependencies for the `jira` Python package. There are a number of tools and frameworks for managing Lambda functions, but for simplicity we will just use `pip` to install dependencies directly to our directory:
```
pip3 install --target ./automation_lambda/ jira
```

#### Copy create_ticket code
Finally, we can just copy-and-paste the code we developed in the last section into `automation_lambda.py`.

#### Shortcut option!
If you don't have time to write your own function and just want to see the end result, we have a fully-implemented solution in `automation_lambda_solution.py`:

```cp automation_lambda/automation_lambda_solutions.py automation_lambda/automation_lambda.py```

#### Apply and test
Push our latest code to AWS with Terraform:
```
./terraform plan
./terraform apply
```
then we can try testing the lambda again. If all went well, we will create a ticket in Jira!

