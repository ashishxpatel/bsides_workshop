# Automated Security Group Remediation

At this point, we have all the pieces we need to automatically respond to events, document them in tickets, and take actions to secure our AWS environment.

#### Create an open security group
Create an open security group for testing. Note that our example code has a hard-coded check to make sure the word "despicable" is in the security group name before it will remove it -- we don't want to accidentally change anything else that might be running in your AWS account.

![security_group_creation.png](images/security_group_creation.png?raw=true "security_group_creation.png")

#### Assign that security group to an instance
![security_group_assignment_1.png](images/security_group_assignment_1.png?raw=true "security_group_assignment_1.png")

![security_group_assignment_2.png](images/security_group_assignment_2.png?raw=true "security_group_assignment_2.png")

#### Set up a new alert
Set up a new Splunk alert using the same query we used for the security group change alert:

```
index=main sourcetype=aws:cloudtrail eventName=*SecurityGroup* NOT eventName=DescribeSecurityGroups
```

![security_group_remediation1.png](images/security_group_remediation1.png?raw=true "security_group_remediation1.png")

![security_group_remediation2.png](images/security_group_remediation2.png?raw=true "security_group_remediation2.png")

The event message field should contain ```remediate_security_groups```
#### Automate all the things!
If everything worked right, the open security group will have been removed and you'll have a new ticket documenting that action.
