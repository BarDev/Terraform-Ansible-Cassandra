
# Outside IP's
outside_ips = ["1.2.3.4/32"]

# Name of VPC
name = "barlow_demo"

# Region where this infrastructure will be created
region = "us-east-2"

# Location of Private key to SSH into instance
key_private_loc = "/Users/barlow/.ssh/somekey.pem"

# Key Name in AWS that relates to the "key_private_loc" above
key_name = "barlow-kp"

# DataStax Tagging Requirments
# https://docs.google.com/document/d/1lWixJ2Nl94Ta0ravVAolqMqHbzzoHsODpiYKcqkK-DM
default_tags = {
    Owner: "Mike Barlow"
    Purpose: "Barlow Demo"
    NeededUntil: ""
    Project: "Barlow Demo"
  } 

# instance_type = "c5.xlarge" # 4 vCPUs, 8 GB Memory
instance_type = "t3.xlarge" # 4 vCPUs, 16 GB Memory

instance_count = 5

