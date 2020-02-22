# Cloud Infrastructure Setup
Instructions on how to deploy cloud infrastructure.

## Local Development Setup

#### Clone this repo to download all course materials:

```bash
git clone https://github.com/ashishpatel-git/bsides_workshop.git
cd bsides_workshop
```

FIXME: maybe change the name of this repo to be the same-ish as the workshop title.

#### Install Terraform

MacOS/Linux Quickstart:
```bash
curl -O https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_darwin_amd64.zip
unzip terraform_0.12.19_darwin_amd64.zip
rm terraform_0.12.19_darwin_amd64.zip
./terraform --version # verify installation
```

More information: https://learn.hashicorp.com/terraform/getting-started/install.html

#### Install AWS CLI and Python development environment

```bash
python3 -m venv venv
source venv/bin/activate
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
pip3 install awscli boto3 jira jupyterlab
aws --version
python3 -c "import boto3; print(boto3.__version__)"
python3 -c "import jira; print(jira.__version__)"
```

More information (AWS): https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#install-bundle-macos

More information (virtualenvironment): https://docs.python.org/3/library/venv.html

#### Subscribe to Splunk Enterprise in AWS Marketplace
We will be using the Splunk Enterprise AMI from the AWS Marketplace, which requires subscribing before we can use it. Visit https://aws.amazon.com/marketplace/pp?sku=7azvchdfh74dcxoiwjhztgpel, click `Continue to Subscribe`, and accept the terms. Don't follow the next prompts to deploy an instance -- we'll do that ourselves later.

This does _not_ cost anything and does not provide a Splunk license, it only allows us to use the AMI (which does come with a baked-in trial license that we will be using).

#### Other options and platforms
You can install AWS CLI, Terraform, and pip with your package manager of choice (brew, yum, apt-get, etc.). Using a Python virtualenvironment is not strictly required, but we do strongly suggest that you use a venv and install dependencies in it with pip.

## Infrastructure with Terraform (Splunk Server, Automation Server, CloudTrail)

#### Log in to your AWS account
https://console.aws.amazon.com/iam

#### Create Terraform user
Navigate to `Access management` -> `Users` -> `Add user` and create a user named `terraform` with `Programmatic access`.

![Adduser](images/adduser1.png?raw=true "Add user")

Attach the AdministratorAccess policy

![Adduser](images/adduser2.png?raw=true "Add user")

Proceed through the "Add tags" page, review your configuration, and create the user. _Download or otherwise save the account credentials now, as they will not be available again._

#### Add AWS credentials
Run `aws configure` and input your access key ID and secret. This will save your credentials to a config file at `~/.aws/credentials`.

```
$ aws configure
AWS Access Key ID [None]: KEYGOESHERE
AWS Secret Access Key [None]: SECRETGOESHERE
Default region name [None]: us-west-2
Default output format [None]:
```

Note that we are using the `us-west-2` AWS region as it is geographically nearby and typically one of the least expensive.

#### Create Infrastructure with Terraform
Initialize your Terraform directory:
```
./terraform init
```

See what Terraform is going to do:
```
./terraform plan
```

Check that the plan looks good, then apply the plan to create these resources in AWS:

```
./terraform apply
```

Now we'll have our Splunk server and CloudTrail created with the appropriate S3 bucket.

When we're done with this infrastructure, we will take it all down with:

```
# Don't run this yet!
./terraform destroy
```

#### Start Jupyter Notebook
Several of the sections in this tutorial are implemented in Jupyter Notebooks. GitHub will render these in your browser, but interacting with them locally (which is strongly suggested) will require starting the Jupyter Notebook server in a NEW terminal:

```
source venv/bin/activate
jupyter notebook
```
