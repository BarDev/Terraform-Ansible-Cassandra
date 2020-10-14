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
   Name = "terraform_learning_dse_sg"
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




  #  # DSEFS inter-node communication port
  #  ingress {
  #     from_port = 5599 
  #     to_port = 5599
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # DSE inter-node cluster communication port
  #  # - 7000: No SSL
  #  # - 7001: With SSL
  #  ingress {
  #     from_port = 7000
  #     to_port = 7001
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # Spark master inter-node communication port
  #  ingress {
  #     from_port = 7077
  #     to_port = 7077
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # JMX monitoring port
  #  ingress {
  #     from_port = 7199
  #     to_port = 7199
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # Port for inter-node messaging service
  #  ingress {
  #     from_port = 8609
  #     to_port = 8609
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # DSE Search web access port
  #  ingress {
  #     from_port = 8983
  #     to_port = 8983
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # Native transport port
  #  ingress {
  #     from_port = 9042
  #     to_port = 9042
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # Native transport port, with SSL
  #  ingress {
  #     from_port = 9142
  #     to_port = 9142
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # Client (Thrift) port
  #  ingress {
  #     from_port = 9160
  #     to_port = 9160
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # Spark SQL Thrift server port
  #  ingress {
  #     from_port = 10000
  #     to_port = 10000
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

  #  # Stomp port: opsc -> agent
  #  ingress {
  #     from_port = 61621
  #     to_port = 61621
  #     protocol = "tcp"
  #     security_groups = [aws_security_group.sg_internal_only.id]
  #  }

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


