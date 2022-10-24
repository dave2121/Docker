# configured aws provider with proper credentials
provider "aws" {
  region    = "us-east-1"
  profile   = "Docker_Engine"
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_subnet" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "docker-sec-gr"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "custom"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker_sg"
  }
}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
# create key pair for the ec2 instance
resource "aws_key_pair" "docker_key" {
  key_name   = "mackey"
  public_key = file("~/.ssh/id_rsa.pub")

}


# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_subnet.id
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  key_name               = aws_key_pair.docker_key.id
  user_data              = file("install_docker.sh")

  tags = {
    Name = "Docker_Engine"
  }
}


# print the ec2's public ipv4 address
output "public_ipv4_address" {
  value = aws_instance.ec2_instance.public_ip
}