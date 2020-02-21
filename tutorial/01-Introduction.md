# If This Then Hack: An Intro to DIY Cloud Security Automation with Python

Security engineers face the daily task of detection, responding, and remediating incidents in both cloud and on-premise environments. Recent high-profile breaches have highlighted that even the organizations we would expect to have fine-tuned and automated security programs often have critical blind spots. Automating your incident response and detection workflows into existing pipelines can save time and manual analyst efforts which result in faster resolution times. There are any number of vendor that will happily take your money, but we can start to build our own DIY alternative with just some artisanal Python and the tools we already have.

Our workshop will discuss the core principles of what it takes to build your own automation tools for cloud security, from detecting events to automatically remediating. We won't be using toy examples: we'll be using the security tools we have used in industry like Splunk and Jira to build realistic end-to-end automation workflows. Students in our workshop will learn how to integrate the following flow 1) Identify an event (in public cloud), 2) Produce and capture the details of the event in Splunk and create a ticket in Jira, 3) Automatically enrich this data and create the appropriate automated remediation response. These steps can be completed to eliminate manual overhead on detection in the cloud as well as proper delegation to the appropriate team (incident response team, compliance, engineering teams, or other). With the use of simple Python scripts students will learn how they can build a simple yet fundamental security automation system. 

The approach to building automation you will learn in this workshop is applicable to any kind of ticket-centric operations environment, not just security. We want to pull back on the curtain on "security automation" and show that it really isn't magic, it's just a bit of code in the right places.

# Requirements
Students should be comfortable with basic Python scripting (at a minimum, able to write functions, loops, and conditionals without consulting documentation) and should be familiar with security terminology. The student who stands to gain the most from this course is one with professional experience in security and an interest in developing new skills in applying programming to automate their work.

## Introduction to public cloud security risks and common security scenarios (Workshop Presentation)
* We will discuss the numerous security events occurring in the public cloud space particularly in AWS where security engineers have to be vigilant
  * Specific examples: public S3 buckets & open security groups
* Next, we will dive into the types of log sources that can be evaluated from a public cloud account in AWS and the details of what we'd want to capture
  * What are the types of log sources?
  * CloudTrail (API)
  * NetFlow (VPC activity)
  * DNS logs (Route53)
* Review common security events and what they look like in CloudTrail
  * Modification of CloudTrail for example
  * EC2 changes, IAM API calls

## Introduction to security automation and the core pieces involved (Workshop Presentation)
* Now we can find events: how do we react to them?
* What automation tool stack will we be using and the benefits of each
  * We'll be using the tools that we actually do use - while not a perfect match for everyone's environments, these are the major components that almost every company works with
  * This is not the easiest way. It's not the simplest. But it reflects real-world patterns that apply to many many scenarios. Logging and compliance matter
  * Jira
    * Documented evidence of a security incident or event
    * Ability to tag to the responding team that is on call
    * Ability to enrich the ticket with details that enhance the overall mean time to resolution (Tagging to service owners etc..)
  * Splunk
    * Ability to collect and store log data from all sources (CloudTrail retention)
    * Pipeline to automate detections and alerting into the right destinations
    * Flow through to Jira, Slack with updated enriched data through the use of lookup tables etc..
  * Slack
    * Instant notification to teams regarding incidents
    * Prioritization of security incidents 
    * Ability to build out slack bots that can do some work for you
* Code review of flows
  * Jira API overview
  * Splunk Python automation overview
  * Slack webhook Python demonstration

## Detect and respond to a security event in the public cloud using automation (Workshop Exercises)
* Set up CloudTrail logging into Splunk
  * Basic add on for the ingestion of S3 CloudTrail logs
* See event ingested in Splunk
  * Verify that we have CloudTrail JSON events coming through
* Create and set up our automation flow to respond to incidents
  * We develop a Splunk query for an alert
  * We create a Splunk saved search: run that query every N minutes, trigger a webhook action when an alert condition is satisfied
  * We write our automation server to receive that webhook and create a ticket 
  * We configure webhooks in Jira to call back to the automation server on ticket creation
  * We add a new to the automation server to receive those webhooks, run lookups/enrichments, take actions (AWS account ID lookup, disable key)
* Build automation workflows to react to these "malicious" actions:
  * An AWS security malicious event occurs, someone has disabled your CloudTrail 
  * API Usage from unauthorized IP outside of your organization
* Validate our automation flow worked and confirm tickets & actions were completed
