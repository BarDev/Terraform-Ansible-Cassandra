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

variable "instance_type" {
  default = "c5a.xlarge" # 4 vCPUs, 8 GB Memory
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
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"

  tags = merge(
   var.default_tags,
   {
    "Name" = "terraform_learning_internal_vpc"
   }
  )
}

# Create a 3 subnets in 3 different
resource "aws_subnet" "sbn" {
  count = 3
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index) # 10.0.0.0/26, 10.0.0.64/26, 10.0.0.128/26
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
   vpc_id = aws_vpc.vpc.id

   ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true  # Incomming traffic must be initiated from instances in this Security Group
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
   vpc_id = aws_vpc.vpc.id

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"] # Can initiate outbound connection to any IP, including the internet
   }

   tags = merge(
     var.default_tags,
     {
       "Name" = "terraform_learning_dse_sg"
     }
   )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

    tags = merge(
     var.default_tags,
     {
       "Name" = "terraform_learning_igw"
     }
   )
}

# Create for traffic to get to the internet
# FYI: When VPC is created, a default route table is also created.
#      All Subnets not explicitly associated with a route table will be inplicitly associated
#      with the default route table 
resource "aws_route" "rt_igw" {
  route_table_id = aws_vpc.vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Not need since any subnet not associated w/ a route table are implicitly associated 
# with default route table
# resource "aws_route_table_association" "a" {
#   route_table_id = aws_vpc.vpc.default_route_table_id
#   subnet_id  =  aws_subnet.sbn[0].id
#}

resource "aws_instance" "dse" {
  ami = data.aws_ami.aws_ubuntu.id
  instance_type = "c5.xlarge"
  count = 3
  subnet_id = aws_subnet.sbn[count.index].id
  availability_zone =  data.aws_availability_zones.azs.names[count.index]
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg_dse_node.id,aws_security_group.sg_admin.id]
  key_name = var.key_name
    
  tags = merge(
    var.default_tags,
    {
      "Name" = "terraform_learning_${count.index}" 
    }
  )
}

# Create and Assing Static Public IP to Each Instance
resource "aws_eip" "eip" {
  vpc = true
  count = 3

  instance = aws_instance.dse[count.index].id
  depends_on = [aws_internet_gateway.igw]
  tags = merge(
    var.default_tags,
    {
        "Name" = "terraform_learning_EIP_${count.index}" 
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

