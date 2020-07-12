variable "name" {
  description = "The name of the project, must be unique"
  default     = "Terraform-AdaT"
}

variable "region" {
  type          = string
  description   = "Region of ECS cluster"
  default       = "us-east-1"
  # default       = "ap-southeast-2"
}

variable "credentials" {
  type          = string
  description   = "default AWS credential profile"
  default       = "c:/Users/adat/.aws/credentials"
}

variable "keyname" {
  type          = string
  default       = "adatkey"
}

variable "pemfile" {
  type          = string
  default       = "c:/Users/adat/.aws/sshKeys/adatkey.pem"
}