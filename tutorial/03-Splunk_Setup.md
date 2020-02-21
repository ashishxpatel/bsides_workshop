# Splunk Configuration
To log in to your Splunk server, find the instance in the AWS EC2 Dashboard and find the Public IP or Public DNS entry for your server. Open a web browser and go to `http://YOUR_IP_OR_DNS:8000/`. If
you just built your infrastructure with Terraform you may have to wait a few minutes while Splunk may starts up.

Log in with username `admin` and password `SPLUNK-$INSTANCE_ID` (copy your instance ID from the EC2 dashboard).

Next we'll want to install the Splunk Add-on for Amazon Web Services and configure our CloudTrail log ingestion.

#### Install Splunk Add-on for Amazon Web Services

 - From main Splunk landing page, `+ Find More Apps`
 - Search for AWS, find the Splunk Add-on for Amazon Web Services
 - Click "Install" and supply Splunk credentials
 - Server settings -> General settings -> enable HTTPS
 - Settings -> Server controls -> Restart Splunk

 - After restarting:
 - Go to Splunk Add-on for Amazon Web Services -> Inputs
 - Create New Input -> CloudTrail -> SQS-Based S3
![NewInput](images/cloudtrail_input_setup.png?raw=true "NewInput")

 - Configure with:
    - Name: aws_cloudtrail
    - AWS account: splunk_role (IAM supplied by infrastructure config)
    - Assume role: leave empty (optional)
    - AWS Region: US West (Oregon)
    - SQS Queue Name: aws_splunk_main_queue
    - SQS Batch Size: 10 (default)
    - Leave others at default
    - Click Submit

![CloudTrailConf](images/cloudtrail_configuration.png?raw=true "CloudTrailConf")

#### Verify that CloudTrail Logs are Ingested
To look at the CloudTrail logs and verify that everything is working correctly, go to the Search & Reporting App and search for
```
index=main sourcetype=aws:cloudtrail
```

Note: It may take around 15 minutes for logs to start appearing in Splunk.
