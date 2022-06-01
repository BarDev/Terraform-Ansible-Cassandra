# *************************************************************
# Variables
# *************************************************************

# Region where this infrastructure will be created
variable "region" {
  default = "us-east-2"
}

# Location of Private key to SSH into instance
variable "key_private_loc" {
    type = string
    default = "/Users/mikebarlow/.ssh/aws-us-east-2-barlow-kp.pem"
}

# Key Name in AWS that relates to the "key_private_loc" above
variable "key_name" {
    type = string
    default = "barlow-kp"
}

# Tagging
# https://docs.google.com/document/d/1lWixJ2Nl94Ta0ravVAolqMqHbzzoHsODpiYKcqkK-DM
variable "default_tags" {
  type    = map
  default = {
    Owner: "Mike Barlow"
    Purpose: "Learning Terraform"
    NeededUntil: "10/12/2020"
    Project: "Learning Terraform"
  } 
}

# *************************************************************
# Providers
# *************************************************************

provider "aws" {
  region  = var.region
  # shared_credentials_file = "/Users/<user name>/.aws/credentials" # Optional
  profile = "default"
}

# *************************************************************
# Data
# *************************************************************

# Find the newest AWS Ubuntu AMI
data "aws_ami" "aws_ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# *************************************************************
# Resources
# *************************************************************

# This uses the default VPC.  It WILL NOT delete it on destroy.
# This is a quick way to get something up and running.
# Creating a VPC is recommeded
# resource "aws_default_vpc" "default" { }


resource "aws_vpc" "terraform_learning_vpc" {
  cidr_block = "10.0.0.0/22"
  tags = merge(
   var.default_tags,
   {
    "Name" = "terraform_learning_internal_vpc"
   }
  )
}


# AWS Secuirty Group for DataStax Enterprise
resource "aws_security_group" "sg_dse_node" {
   name = "terraform_learning_dse_sg"
   vpc_id = aws_vpc.terraform_learning_vpc.id

   # Outbound: All DSE nodes can communicate together 
   egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     self = true
   }

   # Inboud: All DSE nodes can communicate together 
   ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
   }

  tags = merge(
    var.default_tags,
    {
     
    }
  )
}


# *************************************************************
# Outputs
# *************************************************************
output "default_tags" {
  value = var.default_tags
}

output "ubuntu_ami" {
  value = data.aws_ami.aws_ubuntu
}


