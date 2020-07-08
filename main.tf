# Configure the AWS Provider
provider "aws" {
	version									    = "~> 2.0"
  region                      = var.region
  shared_credentials_file     = var.credentials
}

#
# vpc with private && public subnets
#
module "vpc" {
  # source = "./modules/vpc/"
  source = "terraform-aws-modules/vpc/aws"

  # name = "my-vpc"
  # cidr = "10.0.0.0/16"

  # azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  # tags = {
  #   Terraform = "true"
  #   Environment = "dev"
  # }
}

#
# Container_definition
#
module "container_definition" {
  source            = "./modules/ecs_container_definition/"
}

#
# The ecs_service sub-module creates the ECS Service
# 
module "ecs_service" {
  source = "./modules/ecs_service/"
}