FIXME

Teach Splunk searching and setting up alerts.
Exercise: Create an "* | head 1" alert that always fires to create a ticket, disable after testing
Exercise: Create an alert to create a ticket for any security group change.


SecurityGroup changes:
index=main sourcetype=aws:cloudtrail eventName=*SecurityGroup* NOT eventName=DescribeSecurityGroups


Teach AWS SDK part
Exercise: Write a function to find open security groups locally.
Exercise: Add to the lambda and change ticket creation to now also include open security group information
Exercise: Write a function to auto-remediate open security groups locally
Exercise: Add to the lambda and change ticket creation to include details of what was remediated

Finally, we can have students build the whole workflow to disable an access key after access from a country - this can be optional / extra credit for students who are doing well.

