output "public_ip" {
  value       = "${module.my_ec2.public_ip}"
  description = "The public IP of the web server"
}