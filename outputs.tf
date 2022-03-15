output "public_connection_string" {
  description = "To connect to Web server"
  value       = "ssh -i ${module.ssh-key.key_name}.pem ec2-user@${module.ec2.public_ip}"
}

output "private_connection_string" {
  description = "To connect to Database server"
  value       = "ssh -i ${module.ssh-key.key_name}.pem ec2-user@${module.ec2.private_ip}"
}