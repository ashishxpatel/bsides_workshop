# Splunk Configuration
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
