"""Automation Lambda responds to Splunk alerts and takes actions"""

import json
import boto3
import jira
import settings

def lambda_handler(event, context):
    """Handle alerts from Splunk and automate all the things"""
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    action = message["message"]
    alert_data = json.loads(message["event"])
    search_name = message["search_name"]
    print(event)
    if action == "create_ticket":
        summary = f"Splunk Alert: {search_name}"
        print(f"Creating ticket for {summary}")
        create_ticket(summary, json.dumps(alert_data))
    elif action == "remediate_security_groups":
        remediation_summary = "\n".join(remediate_open_security_groups())
        if remediation_summary != "":
            print(f"Creating ticket for {remediation_summary}")
            create_ticket("Remediated security groups", remediation_summary)


def create_ticket(summary, description):
    j = jira.JIRA(
        settings.jira_url,
        basic_auth=(settings.jira_username, settings.jira_password),
    )

    issue = j.create_issue(
        project=settings.jira_project,
        summary=summary,
        description=description,
        issuetype="Task",
    )
    return issue


def open_security_groups():
    """Return all security groups that are allow inbound connections from the """
    ec2_client = boto3.client("ec2")
    security_groups = ec2_client.describe_security_groups(
        Filters=[
            {"Name": "ip-permission.cidr", "Values": ["0.0.0.0/0"]},
        ]
    )
    groups_whitelist = ["allow_splunk_ports_ingress"]
    ports_whitelist = [22, 80, 443, 8080, 8000]
    open_groups = {}
    for sg in security_groups["SecurityGroups"]:
        for permission in sg["IpPermissions"]:
            if sg["GroupName"] not in groups_whitelist and permission["ToPort"] not in ports_whitelist:
                open_groups[sg["GroupId"]] = sg["GroupName"]
    return open_groups

open_security_groups()


def instance_security_groups():
    """Return a summary of all the security group IDs assocated with running instances.

    This format will look like:
        {'i-096e3b9655241f365': ['sg-05777ecea90c47aae'], ...}
    """
    ec2_client = boto3.client("ec2")
    running_instances = ec2_client.describe_instances(
        Filters=[
            {"Name": "instance-state-name", "Values": ["running", "stopped"]},
        ]
    )
    instances = {}
    for reservation in running_instances["Reservations"]:
        for instance in reservation["Instances"]:
            instance_id = instance["InstanceId"]
            for iface in instance["NetworkInterfaces"]:
                instances[instance_id] = []
                for group in iface["Groups"]:
                    instances[instance_id].append(group["GroupId"])
    return instances


def remove_security_group(instance_id, sg_id):
    ec2 = boto3.client('ec2')
    default_group_id = ec2.describe_security_groups(
        Filters=[
            dict(Name='group-name', Values=['default'])
        ]
    )['SecurityGroups'][0]['GroupId']
    this_group_name = ec2.describe_security_groups(
        Filters=[
            dict(Name='group-id', Values=[sg_id])
        ]
    )['SecurityGroups'][0]['GroupName']
    ec2_resource = boto3.resource("ec2")
    # Here we check if the word "despicable" is in the security group and refuse to delete if not.
    # We don't want accidentally delete something!
    if not "despicable" in this_group_name:
        return f"Cowardly refusing to delete non-despicable group {this_group_name} ({sg_id})"
    instance = ec2_resource.Instance(instance_id)
    new_groups = [g["GroupId"] for g in instance.security_groups if g["GroupId"] != sg_id]
    # Security groups can't be empty, so if this list is empty use the default security group
    if not new_groups:
        new_groups = [default_group_id]
    instance.modify_attribute(Groups=new_groups)
    return "Done"


def remediate_open_security_groups():
    open_groups = open_security_groups().keys()
    instance_groups = instance_security_groups()
    removal_summary = []
    for instance, groups in instance_groups.items():
        instance_open_groups = list(set(groups).intersection(open_groups))
        for group in instance_open_groups:
            removal_summary.append(f"Removing {group} from {instance}: {remove_security_group(instance, group)}")
    return removal_summary
