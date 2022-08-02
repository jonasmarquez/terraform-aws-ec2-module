# ------------------------------------------------------------------------------
# COMMON VARIABLES
# ------------------------------------------------------------------------------
locals {
  # COMMON VARIABLES
  region            = "eu-central-1"
  environment       = "testing"
  creator           = "Terraform"
  team              = "IAC"
  entity            = "jonasmarquez"
  ssh_key_pair_name = "jm-terraform-iac-testing"
  ssh_pub_key       = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrGdaCf7W4eiVNpHGFoPj0BSUEe0GdJ2qBCCmzVqbCl jonas@jonasmarquez.com"
  sequence          = "001"
  platform          = "docker"
  docker_version    = "19.03" # Versions Available: 18.09, 19.03, 20.10
  # INDIVIDUAL VARIABLES
  service           = "jenkins"
  container_version = "2.319.3-lts-jdk11"
  nfs_id            = "fs-019faaf794f9c27e6" # (Optional) Just to be used to mount a NFS volume

  tags = {
    Environment       = local.environment
    Creator           = local.creator
    Team              = local.team
    Entity            = local.entity
    Service           = local.service
    Container_Version = local.container_version
    Platform          = local.platform
    Docker_Version    = local.docker_version
    Sequence          = local.sequence
  }
}

# ------------------------------------------------------------------------------
# PROVIDERS
# ------------------------------------------------------------------------------
provider "aws" {
  region = local.region
}

# ------------------------------------------------------------------------------
# CLOUD-INIT CONFIGURATION
# ------------------------------------------------------------------------------

# DATA SOURCE FILE FROM GIT REPOSITORY
data "http" "cloud-init-get" {
  url             = "https://github.com/${local.entity}/linux-cloud-init/raw/main/${local.platform}/${local.platform}-${local.service}.yaml"
  # Optional request headers
  request_headers = {
    Accept = "application/yaml"
  }
}

# DATA SOURCE FILE FROM LOCAL PATH
data "template_file" "cloud-init" {
  template = data.http.cloud-init-get.response_body
  vars     = {
    region            = local.region
    entity            = local.entity
    service           = local.tags.Service
    docker_version    = local.docker_version
    container_version = local.container_version
    ssh_pub_key       = local.ssh_pub_key
    nfs_id            = (local.nfs_id != "" ? "${local.nfs_id}.efs.${local.region}.amazonaws.com" : "")
  }
}

# ------------------------------------------------------------------------------
# AWS INSTANCE
# ------------------------------------------------------------------------------
module "ec2-instance" {
  #source                 = "../../"
  source                 = "git::https://github.com/jonasmarquez/terraform-aws-ec2-module.git?ref=main"
  ami                    = "ami-0d51579f02ac97d77"
  instance_type          = "t2.medium"
  subnet_id              = "subnet-0182aeaed62cf6217"
  vpc_security_group_ids = ["sg-0b5c9b1194751d7f1"] # AWS EC2 Security Group ID
  key_name               = local.ssh_key_pair_name
  user_data              = data.template_file.cloud-init.rendered
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