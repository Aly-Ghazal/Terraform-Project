variable "instance-type" {
  type = string
}
variable "publicInstances-tag-name" {
  type = list(any)
}
variable "privateInstances-tag-name" {
  type = list(any)
}
variable "vpc-id" {

}
variable "publicSubnet_id" {
  
}
variable "privateSubnet_id" {
  
}

variable "public-inline" {
  
}

# # variable "ALB_sg_id" {
  
# # }
variable "private-inline" {
  
}
# variable "bastion_host_ip" {
  
# }