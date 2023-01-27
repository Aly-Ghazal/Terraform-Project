output "vpc-id" {
  value = aws_vpc.main-vpc.id
}
output "publicSubnet" {
  value = "aws_subnet.publicSubnets"
}
output "privateSubnet" {
  value = "aws_subnet.privateSubnets"
}
output "publicSubnet_id" {
  value = [for subnet in aws_subnet.publicSubnets : subnet.id]
}
output "privateSubnet_id" {
  value = [for subnet in aws_subnet.privateSubnets : subnet.id]
}