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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

##
## Resources
##
 # resource "aws_key_pair" "web" {
 #    key_name = "web-key"
 #    public_key = "${file("ssh/test-key.pub")}"
 # }

##
## Modules
##

#
# vpc with private && public subnets
#
module "my_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = "adat"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  # azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"
  name        = "adat"
  vpc_id      = "${module.my_vpc.vpc_id}"
  ingress_rules            = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  egress_rules             = ["all-all"]
  egress_cidr_blocks       = ["0.0.0.0/0"]
}

module "my_ec2" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "ada-ec2"
  instance_count         = 1

  # ami                    = "ami-03d29fac194d41bfa"          #CentOs 7 + nginx
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = ["${module.my_vpc.default_security_group_id}","${module.security_group.this_security_group_id}"]
  subnet_id              = "${module.my_vpc.public_subnets[0]}"

    user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
# connection {
#         user = "ec2-user"
#         private_key = "${file("ssh/test-key")}"
#         host = "${module.my_ec2.public_ip}"
#     }

# provisioner "file" {
#         source = "./html/index.html"
#         destination = "/tmp/index.html"
#  }

# provisioner "remote-exec" {
#     inline = [

#               "sudo yum install httpd -y",
#               "sudo cp /tmp/index.html /var/www/html/index.html"    
#               ]
#   }

# provisioner "remote-exec" {
#     scripts = [
#                "scripts/web.sh"
#               ]
#    }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# resource "aws_instance" "web" {
#   ami           = "${data.aws_ami.ubuntu.id}"
#   instance_type = "t2.micro"
#   # vpc_security_group_ids      = ["${data.aws_security_group.selected.id}"]
#   # subnet_id                   = "${data.aws_subnet.selected.id}"

#   tags = {
#     Name = "AdaTanInst"
#   }
# }


# #
# # Container_definition
# #
# module "container_definition" {
#   source            = "./modules/ecs_container_definition/"
# }


# #
# # The ecs_service sub-module creates the ECS Service
# # 
# module "ecs_service" {
#   source = "./modules/ecs_service/"
#   name = var.name

#   vpc_id     = "${module.vpc.vpc_id}"
#   subnet_ids = ["${module.vpc.private_subnets}"]

#   vpc_security_group_ids = [data.aws_security_group.selected.id]

#   # ec2_disk_encryption = "true"
#   tags = local.tags
# }


# data "aws_vpc" "selected" {
#   default = true
# }

# data "aws_availability_zones" "available" {
# }

# data "aws_subnet" "selected" {
#   availability_zone = data.aws_availability_zones.available.names[0]
#   default_for_az    = true
#   vpc_id            = data.aws_vpc.selected.id
# }

# data "aws_security_group" "selected" {
#   name   = "default"
#   vpc_id = data.aws_vpc.selected.id
# }

# resource "aws_security_group_rule" "allow_all" {
#   type              = "ingress"
#   from_port         = "0"
#   to_port           = "65535"
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = data.aws_security_group.selected.id
# }

# module "ecs_cluster" {
#   # source  = "blinkist/airship-ecs-cluster/aws"
#   # version = "v1.0.0"
#   source = "github.com/blinkist/terraform-aws-airship-ecs-cluster?ref=v1.0.0" # Terraform registry doesn't have v1.0.0 yet

#   name = "${terraform.workspace}-cluster"

#   vpc_id     = data.aws_vpc.selected.id
#   subnet_ids = [data.aws_subnet.selected.id]

#   vpc_security_group_ids = [data.aws_security_group.selected.id]

#   cluster_properties = {
#     # ec2_instance_type defines the instance type
#     ec2_instance_type = "t2.micro"
#     ec2_key_name      = ""
#     # ec2_asg_min defines the minimum size of the autoscaling group
#     ec2_asg_min = "1"
#     # ec2_asg_max defines the maximum size of the autoscaling group
#     ec2_asg_max = "1"
#     # ec2_disk_size defines the size in GB of the non-root volume of the EC2 Instance
#     ec2_disk_size = "10"
#     # ec2_disk_type defines the disktype of that EBS Volume
#     ec2_disk_type = "gp2"
#     # block_metadata_service blocks the aws metadata service from the ECS Tasks true / false, this is preferred security wise
#     block_metadata_service = false
#   }

#   # ec2_disk_encryption = "true"
#   tags = local.tags
# }
