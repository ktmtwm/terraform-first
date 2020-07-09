# Configure the AWS Provider
provider "aws" {
	version									    = "~> 2.0"
  region                      = var.region
  shared_credentials_file     = var.credentials
}

##
## Locals
##

locals {
  tags = {
    Environment = terraform.workspace
  }
}

##
## Data Sources
##

data "aws_vpc" "selected" {
  default = true
}

data "aws_availability_zones" "available" {
}

data "aws_subnet" "selected" {
  availability_zone = data.aws_availability_zones.available.names[0]
  default_for_az    = true
  vpc_id            = data.aws_vpc.selected.id
}

data "aws_security_group" "selected" {
  name   = "default"
  vpc_id = data.aws_vpc.selected.id
}


##
## Resources
##

resource "aws_security_group_rule" "allow_all" {
  type              = "ingress"
  from_port         = var.echo_port
  to_port           = var.echo_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.selected.id
}

resource "aws_security_group_rule" "allow_user" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "65535"
  protocol          = "tcp"
  # cidr_blocks       = [format("%s/%s", trimspace(data.http.icanhazip.body), "32")]
  security_group_id = data.aws_security_group.selected.id
}

# resource "aws_security_group_rule" "allow_nlb_health_checks" {
#   type      = "ingress"
#   from_port = "32768"
#   to_port   = "65535"
#   protocol  = "tcp"
#   cidr_blocks = formatlist(
#     "%s/32",
#     sort(
#       distinct(
#         compact(concat([""], data.aws_network_interface.nlb.private_ips)),
#       ),
#     ),
#   )
#   security_group_id = data.aws_security_group.selected.id
# }

# resource "aws_lb" "this" {
#   name               = "${terraform.workspace}-service-nlb"
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = [data.aws_subnet.selected.id]

#   enable_deletion_protection       = false
#   enable_cross_zone_load_balancing = true

#   tags = local.tags
# }


##
## Modules
##

#
# vpc with private && public subnets
#
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "ecs_cluster" {
  # source  = "blinkist/airship-ecs-cluster/aws"
  # version = "v1.0.0"
  source = "github.com/blinkist/terraform-aws-airship-ecs-cluster?ref=v1.0.0" # Terraform registry doesn't have v1.0.0 yet

  name = "${terraform.workspace}-cluster"

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = [data.aws_subnet.selected.id]

  vpc_security_group_ids = [data.aws_security_group.selected.id]

  cluster_properties = {
    # ec2_instance_type defines the instance type
    ec2_instance_type = "t2.micro"
    ec2_key_name      = ""
    # ec2_asg_min defines the minimum size of the autoscaling group
    ec2_asg_min = "1"
    # ec2_asg_max defines the maximum size of the autoscaling group
    ec2_asg_max = "1"
    # ec2_disk_size defines the size in GB of the non-root volume of the EC2 Instance
    ec2_disk_size = "10"
    # ec2_disk_type defines the disktype of that EBS Volume
    ec2_disk_type = "gp2"
    # block_metadata_service blocks the aws metadata service from the ECS Tasks true / false, this is preferred security wise
    block_metadata_service = false
  }

  # ec2_disk_encryption = "true"
  tags = local.tags
}


#
# Container_definition
#
module "container_definition" {
  source            = "./modules/ecs_container_definition/"
}

# #
# # The ecs_service sub-module creates the ECS Service
# # 
# module "ecs_service" {
#   source = "./modules/ecs_service/"
# }