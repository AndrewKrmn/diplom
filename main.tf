# main.tf

# Створюємо Security Group для SSH доступу
resource "aws_security_group" "ssh_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security Group for SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Створюємо EC2 інстанс
resource "aws_instance" "ubuntu_instance" {
  ami                         = "ami-005fc0f236362e99f"
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ssh_sg.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  user_data = file("install.sh")

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }
}
