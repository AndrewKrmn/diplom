provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "InternetGateway"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "RouteTable"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true 

  tags = {
    Name = "Subnet"
  }
}

resource "aws_security_group" "DefaultTerraformsSG" {
  name        = "DefaultTerraformsSG"
  description = "Default Security Group allowing all traffic"
  vpc_id      = aws_vpc.my_vpc.id

  # Вхідний трафік (Ingress) для всього трафіку
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Дозволяє весь трафік
    cidr_blocks = ["0.0.0.0/0"]  # Дозволяє доступ з будь-якої IP-адреси
  }

  # Вихідний трафік (Egress) для всього трафіку
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Дозволяє весь трафік
    cidr_blocks = ["0.0.0.0/0"]  # Дозволяє доступ до будь-якої IP-адреси
  }

  # Доступ до порту 5601 (Ingress) для Kibana
ingress {
  from_port   = 5601
  to_port     = 5601
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Дозволяє доступ з будь-якої IP-адреси
}


  # Доступ до порту 9200 (Ingress) для Elasticsearch
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Доступ до порту 5044 (Ingress)
  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Доступ до порту 9100 (Ingress)
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DefaultTerraformsSG"
  }
}

# Створення EC2 інстанції
resource "aws_instance" "EC2-Instance" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t3.large"
  key_name               = "aws"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.DefaultTerraformsSG.id]

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 40
    volume_type           = "standard"
    delete_on_termination = true
    tags = {
      Name = "root-disk"
    }
  }

  user_data = file("./elk-start.sh")

  tags = {
    Name = "EC2-Instance"
  }
}

# Асоціація вже існуючої Elastic IP з EC2 інстанцією
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.EC2-Instance.id
  allocation_id = "eipalloc-02cbbb47eac070c46"
}

