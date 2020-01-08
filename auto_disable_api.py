import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Function to disable access key so it can no longer be used


def disable_access(accessKey, userName, country):
    # Create IAM client
    iam = boto3.client("iam")
    # Update access key to be active
    try:
        iam.update_access_key(
            AccessKeyId=accessKey, Status="Inactive", UserName=userName
        )
        logger.info("Succesfully disabled accesskey for " + userName)
    except:
        logger.info("Did not disable accesskey for " + userName)


def lambda_handler(event, context):
    user_key_id = event["Records"][0]["Sns"]["Message"]
    user_key_message_json = json.loads(user_key_id)
    identity_information = user_key_message_json["message"]
    accessKey, userName, country = identity_information.split()
    disable_access(accessKey, userName, country)
