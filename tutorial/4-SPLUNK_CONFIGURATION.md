# Splunk Configuration
To log in to your Splunk server, find the instance in the AWS EC2 Dashboard and find the Public IP or Public DNS entry for your server. Open a web browser and go to `http://YOUR_IP_OR_DNS:8000/`.

Log in with username `admin` and password `SPLUNK-$INSTANCE_ID` (copy your instance ID from the EC2 dashboard).

Next we'll want to install the Splunk Add-on for Amazon Web Services and configure our CloudTrail log ingestion.

1) Install Splunk Add-on for Amazon Web Services

 - From main Splunk landing page, `+ Find More Apps`
 - Search for AWS, find the Splunk Add-on for Amazon Web Services
 - Click "Install" and supply Splunk credentials
 - Optional: Servert settings -> General settings -> enable HTTPS
 - Settings -> Server controls -> Restart Splunk

 - After restarting (or before, whatever):
 - Go to Splunk Add-on for Amazon Web Services -> Inputs
 - Create SQS-Based S3 input
    - Name: aws_cloudtrail
    - AWS account: splunk_role (IAM supplied by infrastructure config)
    - Assume role: leave empty (optional)
    - AWS Region: US West (Oregon)
    - SQS Queue Name: aws_splunk_main_queue
    - SQS Batch Size: 10 (default)
    - Leave others at default
    - Click Update

* FIXME: Update with screenshots
* FIXME Maybe: Automate this setup?

## Searching and Alerting with Splunk
1) Look at CloudTrail logs in Splunk

- Go back to Search & Reporting App, search `index=main sourcetype=aws:cloudtrail`
- See Cloudtrail logs!!

2) Walk through creation of an alert that writes to SQS




Start with small Python snippets that will be expanded

1) Local on laptop or in a Linux EC2 install boto and start exploring with either small script or interactive terminal.

2) View events in SNS queue (see the output from that Splunk alert)

3) View and change security groups


Install Splunk Add On tarball
Enabled HTTPS for Splunk
Reboot
Click on Splunk Add On button on left
splunk magically knows it has IAM role
Inputs
 - SQS-based S3
 aws_cloudtrail
 splunk_role
 us west
 aws_splunk_main_queue
 SQS batch 10
 Cloudtrail decoder

logs should magically show up in splunk


