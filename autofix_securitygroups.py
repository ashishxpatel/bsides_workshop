import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Function to inspect each security group


def inspect_security_group(ec2, sg_id):
    sg = ec2.SecurityGroup(sg_id)
    open_cidrs = []
    for i in range(len(sg.ip_permissions)):
        to_port = ""
        ip_proto = ""
        if "ToPort" in sg.ip_permissions[i]:
            to_port = sg.ip_permissions[i]["ToPort"]
        if "IpProtocol" in sg.ip_permissions[i]:
            ip_proto = sg.ip_permissions[i]["IpProtocol"]
            if "-1" in ip_proto:
                ip_proto = "All"
        for j in range(len(sg.ip_permissions[i]["IpRanges"])):
            cidr_string = "%s %s %s" % (
                sg.ip_permissions[i]["IpRanges"][j]["CidrIp"],
                ip_proto,
                to_port,
            )
            if sg.ip_permissions[i]["IpRanges"][j]["CidrIp"] == "0.0.0.0/0":
                open_cidrs.append(cidr_string)
    return open_cidrs


# Function to remove any bad SGs that are open to 0.0.0.0/0


def sg_cleaner():
    status = ""
    client = boto3.client("ec2")
    regions = [region["RegionName"] for region in client.describe_regions()["Regions"]]
    for x in regions:
        ec2 = boto3.resource("ec2", region_name=x)
        instances = ec2.instances.filter(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        for instance in instances:
            sg = []
            if instance.tags:
                for i in range(len(instance.tags)):
                    if instance.tags[i]["Key"] == "Name":
                        instance_name = instance.tags[i]["Value"]
                for i in range(len(instance.security_groups)):
                    sg.append(instance.security_groups[i]["GroupId"])
            try:
                publicIP = instance.public_ip_address
            except:
                publicIP = "N/A"
            for eachsg in sg:
                if len(inspect_security_group(ec2, eachsg)) != 0:
                    sg.remove(eachsg)
                    instance.modify_attribute(Groups=sg)
                    logger.info(
                        "Removing open SG on: Name: {} ID: {} Public IP:{} Region:{}\n".format(
                            instance_name, instance.id, publicIP, x
                        )
                    )
                    logger.info(
                        "Security Group Removed: SG ID: {} Rule Details: {}\n".format(
                            eachsg, str(inspect_security_group(ec2, eachsg))
                        )
                    )
    return status


def lambda_handler(event, context):
    sg_cleaner()
