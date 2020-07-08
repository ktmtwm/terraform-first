variable "name" {
  description = "The name of the project, must be unique"
  default     = "Terraform-AdaT"
}

variable "region" {
  type          = string
  description   = "Region of ECS cluster"
  default       = "us-east-1"
}

variable "credentials" {
  type          = string
  description   = "default AWS credential profile"
  default       = "~/.aws/credentials"
}

