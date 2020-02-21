# Splunk Searching and Alerting

#### Basic Searching - Security Group Changes
Splunk is easy to get started with because its query language is very flexible. Let's start by developing a search to find changes to security groups. Start with a simple query like:

```
index=main sourcetype=aws:cloudtrail
```

to view all CloudTrail events. The left sidebar shows a summary of values for each field in our search results. Let's try to narrow the search down to changes to Security Groups:

```
index=main sourcetype=aws:cloudtrail eventName=*SecurityGroup*
```

Most of these events appear to be DescribeSecurityGroups, which aren't very interesting since we are looking for changes. Let's exclude those:

```
index=main sourcetype=aws:cloudtrail eventName=*SecurityGroup* NOT eventName=DescribeSecurityGroups
```

This is now pretty useful - it looks like only changes to security groups!

#### Basic Alerting - Create Tickets for Security Group Changes

Now let's create an alert to create a ticket for any security group change. Take the query above and turn it into an alert:

![security_group_change_with_trigger.png](images/security_group_change_with_trigger.png?raw=true "security_group_change_with_trigger.png")

There are a couple of weird things in this alert, but we're doing them on purpose for testing. First, we've got a lookback of 24 hours, but the cron schedule `* * * * *` means we will run this every minute! This guarantees that we will get an alert right away and it will keep firing so we can test our lambda. However, that would result in _lots_ of duplicate alerts, so adding the throttling setting makes this more reasonable.

Next we add an AWS SNS alert action that will trigger our lambda function:

![security_group_change_setup_2.png](images/security_group_change_setup_2.png?raw=true "security_group_change_setup_2.png")

Save this alert and as soon as it fires we should have a Jira ticket created for the alert!

