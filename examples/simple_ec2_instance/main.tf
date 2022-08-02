# ------------------------------------------------------------------------------
# COMMON VARIABLES
# ------------------------------------------------------------------------------
locals {
  region = "eu-central-1"
  name   = "test-ec2-module-instance"

  tags = {
    Name        = local.name
    Entity      = "Company Name"
    Team        = "IAC"
    Creator     = "Terraform"
    Environment = "test"
  }
}

# ------------------------------------------------------------------------------
# PROVIDERS
# ------------------------------------------------------------------------------
provider "aws" {
  region = local.region
  default_tags {
    tags = local.tags
  }
}

# ------------------------------------------------------------------------------
# AWS INSTANCE
# ------------------------------------------------------------------------------
module "ec2-instance" {
  source = "git::https://github.com/jonasmarquez/terraform-aws-ec2-module.git?ref=main"
  #source                 = "../"
  ami                    = "ami-0d51579f02ac97d77"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-046982cad1aab2fe1"
  vpc_security_group_ids = ["sg-0783ce041db3ce42c"]
  key_name               = "<SSH-KEY-PAIR-NAME>"
  tags                   = local.tags
}

# ------------------------------------------------------------------------------
# TERRAFORM OUTPUT
# ------------------------------------------------------------------------------
output "private_ip" {
  value = module.ec2-instance.private_ip
}

output "public_ip" {
  value = module.ec2-instance.public_ip
}

output "instance_id" {
  value = module.ec2-instance.id
}

output "public_dns" {
  value = "http://${module.ec2-instance.public_dns}"
}