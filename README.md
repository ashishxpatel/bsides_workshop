# If This Then Hack
### An Intro to DIY Cloud Security Automation with Python
This tutorial addresses the core principles of what it takes to build your own automation tools for cloud security, from detecting events to automatically remediating events, with heavy emphasis on using Python scripts to interact with the AWS API.

We won't be using toy examples: we'll be using the security tools we have used in industry like Splunk and Jira to build realistic end-to-end automation workflows. Students in our workshop will learn how to integrate the following flow 1) Identify an event (in public cloud), 2) Produce and capture the details of the event in Splunk and create a ticket in Jira, 3) Automatically enrich this data and create the appropriate automated remediation response. These steps can be completed to eliminate manual overhead on detection in the cloud as well as proper delegation to the appropriate team (incident response team, compliance, engineering teams, or other). With the use of simple Python scripts students will learn how they can build a simple yet fundamental security automation system. 

[Introduction](tutorial/01-Introduction.md)

[Infrastructure Setup with Terraform](tutorial/02-Infrastructure_Setup.md)

[Setting up Splunk](tutorial/03-Splunk_Setup.md)

[Working with the Jira API](tutorial/04-Working_with_Jira_SDK.ipynb)

[Building Lambda Functions](tutorial/05-AWS_Lambda.md)

[Searching and Alerting with Splunk](tutorial/06-Splunk_Searching_and_Alerting.md)

[Remediating Open Security Groups with the AWS API](tutorial/07-Remediating_Open_Security_Groups_AWS_API.ipynb)

[Automated Security Group Remediation](tutorial/08-Automated_Security_Group_Remediation.md)

[Disabling API Keys on Suspicious Access](tutorial/09-Disable_Key_on_Suspicious_Access.md)
