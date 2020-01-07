# bsides_workshop
Instructions on how to deploy cloud infrastructure for the BSides 2020 SF workshop demo:


1) Install Terraform on your local CLI - https://learn.hashicorp.com/terraform/getting-started/install.html. 

2) Download and copy the provided TF files found in this repo.

3) Create an IAM admin user called "terraform" with the "Administrator" policy attached.

4) Use the AWS secrets to input them into your local AWS CLI configuration for TF to use. 

5) Run ```terraform init``` to initialize your TF directory. Once that is completed, you can run a ```terraform plan``` commmand to see what all the potential infrastructure will look like.

6) Once everything checks out we can then run a ```terraform apply``` to configure our resources inside of AWS.

7) Now we'll have our Splunk server and CloudTrail created with the appropriate S3 bucket. Next we'll want to install the AWS add on inside of Splunk so we can easily configure our CloudTrail ingestion.

8) Hit ```install app from file``` while inside of Splunk and install the provided tar file. 

9) Now we'll need to configure ingestion to Splunk from CloudTrail, we'll need to create an IAM user that has 
