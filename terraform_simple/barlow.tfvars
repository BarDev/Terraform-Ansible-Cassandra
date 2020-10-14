
# Region where this infrastructure will be created
region = "us-east-1"


# Location of Private key to SSH into instance
key_private_loc = "/Users/mikebarlow/.ssh/aws_datastax_barlow_kp.pem"


# Key Name in AWS that relates to the "key_private_loc" above
key_name = "barlow_kp"

# DataStax Tagging Requirments
# https://docs.google.com/document/d/1lWixJ2Nl94Ta0ravVAolqMqHbzzoHsODpiYKcqkK-DM
default_tags = {
    Owner: "mike.barlow@company.com"
    Purpose: "Learning Terraform"
    NeededUntil: "10/12/2020"
    Project: "Learning Terraform"
  } 

instance_type = "c5a.xlarge" # 4 vCPUs, 8 GB Memory

instance_count = 3
