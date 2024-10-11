# outputs.tf

output "instance_public_ip" {
  description = "Публічна IP-адреса EC2 інстансу"
  value       = aws_instance.ubuntu_instance.public_ip
}

output "instance_id" {
  description = "ID EC2 інстансу"
  value       = aws_instance.ubuntu_instance.id
}
