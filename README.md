# If This Then Hack
### An Intro to DIY Cloud Security Automation with Python
This tutorial addresses the core principles of what it takes to build your own automation tools for cloud security, from detecting events to automatically remediating events, with heavy emphasis on using Python scripts to interact with the AWS API.

We won't be using toy examples: we'll be using the security tools we have used in industry like Splunk and Jira to build realistic end-to-end automation workflows. Students in our workshop will learn how to integrate the following flow 1) Identify an event (in public cloud), 2) Produce and capture the details of the event in Splunk and create a ticket in Jira, 3) Automatically enrich this data and create the appropriate automated remediation response. These steps can be completed to eliminate manual overhead on detection in the cloud as well as proper delegation to the appropriate team (incident response team, compliance, engineering teams, or other). With the use of simple Python scripts students will learn how they can build a simple yet fundamental security automation system. 

[Introduction](tutorial/01-Introduction.md)

[Infrastructure Setup with Terraform](tutorial/02-Infrastructure_Setup.md)

[Exploring Infrastructure Internals via AWS API](tutorial/2.5-Digging_Into_SQS_SNS_S3_logs.ipynb )

[Setting up Splunk](tutorial/4-SPLUNK_CONFIGURATION.md)

[Searching and Alerting with Splunk](tutorial/5-SPLUNK_SEARCHING_AND_ALERTING.md)

[Remediating Open Security Groups with the AWS API](tutorial/6-Remediating_Open_Security_Groups_AWS_API.ipynb)

[Integrating with the Jira API](tutorial/7-Working_with_JIRAA_SDK.ipynb)

[Deploying Lambda Functions](tutorial/8-ANOTHER_LAMBDA_WORKFLOW.md)
