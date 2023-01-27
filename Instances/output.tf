output "publicSG" {
  value = aws_security_group.PublicEC2_sg.*.id
  #[for sg in aws_security_group.PublicEC2_sg : sg.id]
}
output "PublicInstances_id" {
  value = aws_instance.Public_Ec2s_From_Terraform
}
output "PrivateInstances_id" {
  value = aws_instance.Private_Ec2s_From_Terraform
}
output "SGPublicEC2-ID" {
  value = aws_security_group.PublicEC2_sg.id
}

output "publicInstance_publicip" {
  value = aws_instance.Public_Ec2s_From_Terraform.public_ip
}