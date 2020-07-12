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
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
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
  enable_dns_hostnames = true

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

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.keyname}"
  public_key = "${tls_private_key.rsa.public_key_openssh}"
}

resource "local_file" "cloud_pem" { 
  filename = "${var.pemfile}"
  content = tls_private_key.rsa.private_key_pem
}


data "template_file" "install-docker" {
  template = "${file("./docker-scripts/install-docker-nginx.sh")}"
}

resource "aws_instance" "web"{
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = ["${module.my_vpc.default_security_group_id}","${module.security_group.this_security_group_id}"]
  subnet_id              = "${module.my_vpc.public_subnets[0]}"
  associate_public_ip_address = true

  key_name      = "${aws_key_pair.generated_key.key_name}"

  connection {
    user = "ubuntu"
    type = "ssh"
    private_key = file("${var.pemfile}")
    host = "${aws_instance.web.public_ip}"
  }


  # run a remote provisioner on the instance after creating it.
  provisioner "file" {
      source = "./docker-scripts/"
      destination = "/tmp/"
  }

  user_data               = "${data.template_file.install-docker.template}"

  # provisioner "remote-exec" {
  #    inline = [
  #         "python3 /tmp/calculate_works.py"
  #     ]
  # } 

}


