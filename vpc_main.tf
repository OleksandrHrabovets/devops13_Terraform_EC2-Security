terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "availability" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "KOWO-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "KOWO-Internet-Gateway"
  }
}


resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/20", 8, count.index)
  availability_zone = element(data.aws_availability_zones.availability.names, count.index)

  tags = {
    Name = "KOWO-Public-Subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.16.0/20", 8, count.index)
  availability_zone = element(data.aws_availability_zones.availability.names, count.index)

  tags = {
    Name = "KOWO-Private-Subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "database" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.32.0/20", 8, count.index)
  availability_zone = element(data.aws_availability_zones.availability.names, count.index)

  tags = {
    Name = "KOWO-Database-Subnet-${count.index + 1}"
  }
}


resource "aws_route_table" "public" {
  count  = 3
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "KOWO-Public-Route-Table-${count.index + 1}"
  }
}

resource "aws_route" "public" {
  count                  = 3
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "KOWO-Private-Route-Table-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "aws_route_table" "database" {
  count  = 3
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "KOWO-Database-Route-Table-${count.index + 1}"
  }
}

resource "aws_route_table_association" "database" {
  count          = 3
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

output "vpc_main_id" {
  value = aws_vpc.main.id
}

output "subnet_public_ids" {
  value = [
    for x in aws_subnet.public:
    x.id
  ]
}

output "subnet_private_ids" {
  value = [
    for x in aws_subnet.private:
    x.id
  ]
}

output "subnet_database_ids" {
  value = [
    for x in aws_subnet.database:
    x.id
  ]
}