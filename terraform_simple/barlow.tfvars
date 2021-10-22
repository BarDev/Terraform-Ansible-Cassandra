# Outside IP's
outside_ips = ["67.100.100.100/32"]

# Name of VPC
name = "square_demo"

# Region where this infrastructure will be created
region = "us-west-2"

# Location of Private key to SSH into instance
key_private_loc = "/Users/mikebarlow/.ssh/aws_private_key.pem"

# Key Name in AWS that relates to the "key_private_loc" above
key_name = "barlow-kv"

# DataStax Tagging Requirments
# https://docs.google.com/document/d/1lWixJ2Nl94Ta0ravVAolqMqHbzzoHsODpiYKcqkK-DM
default_tags = {
    Owner: "mike.barlow@company.com"
    Purpose: "Square Demo"
    NeededUntil: "10/12/2020"
    Project: "Square Demo"
  } 

instance_type = "c5.xlarge" # 4 vCPUs, 8 GB Memory

instance_count = 3
