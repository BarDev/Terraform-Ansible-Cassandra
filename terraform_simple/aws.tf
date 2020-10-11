# *************************************************************
# Variables
# *************************************************************

# Region where this infrastructure will be created
variable "region" {
  default = "us-east-1"
}

# Location of Private key to SSH into instance
variable "key_private_loc" {
    type = string
    default = "/Users/mikebarlow/.ssh/aws_datastax_barlow_kp.pem"
}

# Key Name in AWS that relates to the "key_private_loc" above
variable "key_name" {
    type = string
    default = "barlow_kp" 
}

# DataStax Tagging Requirments
# https://docs.google.com/document/d/1lWixJ2Nl94Ta0ravVAolqMqHbzzoHsODpiYKcqkK-DM
variable "default_tags" {
  type    = map
  default = {
    Owner: "mike.barlow@datastax.com"
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
  profile = "fieldops"
}

# *************************************************************
# Data
# *************************************************************

# Get Availability Zones
data "aws_availability_zones" "azs" {
    state = "available"
}

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


# Create AWS VPC
resource "aws_vpc" "terraform_learning_vpc" {
  cidr_block = "10.0.0.0/22"

  tags = merge(
   var.default_tags,
   {
    "Name" = "terraform_learning_internal_vpc"
   }
  )
}

# Create a subnet for the AZ within the regional VPC
resource "aws_subnet" "terraform_learning_subnets" {
  count = 3
  vpc_id     = aws_vpc.terraform_learning_vpc.id
  cidr_block = cidrsubnet(aws_vpc.terraform_learning_vpc.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags = merge(
    var.default_tags,
    {
      "Name" = "terraform_learning_Subnet_${count.index}" 
    }
  )
}


# All nodes DSE nodes can communicate together
resource "aws_security_group" "sg_dse_node" {
   name = "terraform_learning_dse_sg"
   vpc_id = aws_vpc.terraform_learning_vpc.id

   egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     self = true # This what makes it work
   }

   ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true  # This what makes it work
   }

  tags = merge(
   var.default_tags,
   {
    "Name" = "terraform_learning_dse_sg"
   }
  )
}

# Create Security to Acccess Nodes over SSh
resource "aws_security_group" "sg_admin" {
   name = "terraform_learning_admin_sg"
   vpc_id = aws_vpc.terraform_learning_vpc.id

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = merge(
   var.default_tags,
   {
    "Name" = "terraform_learning_dse_sg"
   }
  )
}
# *************************************************************
# Outputs
# *************************************************************
# output "default_tags" {
#   value = var.default_tags
# }

# output "ubuntu_ami" {
#   value = data.aws_ami.aws_ubuntu
# }


output "AZs" {
  value = data.aws_availability_zones.azs
}

