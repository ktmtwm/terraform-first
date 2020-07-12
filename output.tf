output "public_ip" {
  # value       = "${module.my_ec2.public_ip}"
  value       = "${aws_instance.web.public_ip}"
  description = "The public IP of the web server"
}

# output "sshkey" {
#   sensitive = true
#   value = "${aws_key_pair.generated_key.key_name}"
# }