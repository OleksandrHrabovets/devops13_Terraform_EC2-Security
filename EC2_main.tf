data "aws_ami" "ubuntu"{
    most_recent = true

    filter {
      name = "name"
      values = ["ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
      name   = "root-device-type"
      values = ["ebs"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access-sg"
  description = "Allow SSH access to EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "SSH Access Security Group"
  }
}


resource "aws_instance" "instance_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true

  tags = {
    Name = "Instance-Public"
    VPC  = aws_vpc.main.id
  }
}

resource "aws_instance" "instance_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "Instance-Privat"
    VPC  = aws_vpc.main.id
  }
}
