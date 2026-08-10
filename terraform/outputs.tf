output "instance_public_ip" {
  value = aws_instance.oocaa.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/oocaa-key ubuntu@${aws_instance.oocaa.public_ip}"
}