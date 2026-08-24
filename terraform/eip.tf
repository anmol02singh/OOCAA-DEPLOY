resource "aws_eip" "oocaa" {
  instance = aws_instance.oocaa.id
  domain   = "vpc"
  tags = { Name = "oocaa-eip" }
}

output "elastic_ip" {
  value = aws_eip.oocaa.public_ip
}