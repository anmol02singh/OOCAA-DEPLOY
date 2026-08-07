resource "aws_vpc" "oocaa" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "oocaa-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.oocaa.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "oocaa-public-subnet" }
}

resource "aws_internet_gateway" "oocaa" {
  vpc_id = aws_vpc.oocaa.id
  tags = { Name = "oocaa-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.oocaa.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oocaa.id
  }
  tags = { Name = "oocaa-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
