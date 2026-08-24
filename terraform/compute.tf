data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "oocaa" {
  key_name = "oocaa-key"
  public_key = file(pathexpand("~/.ssh/oocaa-key.pub"))
}

resource "aws_security_group" "oocaa" {
  name = "oocaa-sg"
  description = "ssh from me, app ports from anywhere"
  vpc_id = aws_vpc.oocaa.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    description = "UI"
    from_port = 3001
    to_port = 3001
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "API"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "oocaa-sg" }
}

resource "aws_instance" "oocaa" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.oocaa.id]
  key_name = aws_key_pair.oocaa.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_ecr.name
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    usermod -aG docker ubuntu
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
  EOF

  tags = { Name = "oocaa-server" }
}