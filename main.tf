module "myNetwork" {
  source                    = "./VPC"
  VPC-cidr                  = "10.0.0.0/16"
  VPC-tag-name              = "Terraform-Project-Network"
  publicSubnets-cidr        = ["10.0.0.0/24", "10.0.2.0/24"]
  Subnet-Availability-zones = ["eu-central-1a", "eu-central-1b"]
  publicSubnets-tag-names   = ["publicsubnet-01", "publicsubnet-02"]
  privateSubnets-cidr       = ["10.0.1.0/24", "10.0.3.0/24"]
  privateSubnets-tag-names  = ["privatesubnet-01", "privatesubnet-02"]
}


module "Instances" {
  source                    = "./Instances"
  instance-type             = "t2.micro"
  publicInstances-tag-name  = ["PublicInstance01", "PublicInstance02"]
  privateInstances-tag-name = ["PrivateInstance01", "PrivateInstance02"]
  vpc-id                    = module.myNetwork.vpc-id
  #publicSubnet_id = aws_subnet.publicSubnets[count.index].id
  count= length(module.myNetwork.publicSubnet_id)
  publicSubnet_id           = module.myNetwork.publicSubnet_id[count.index]
  privateSubnet_id          = module.myNetwork.privateSubnet_id[count.index]
  #ALB_sg_id=module.alb-all.privateLB_sg_id

  public-inline = [
      "echo 'hello world'",
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${module.alb-all.private_LB_DNS}; \n  } \n}' > default",
      "sudo mv default /etc/nginx/sites-enabled/default",
      "sudo systemctl restart nginx",
  ]

  private-inline=[
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "private_ip=`sudo curl http://169.254.169.254/latest/meta-data/local-ipv4`",
      "sudo echo 'Hello from private instance ' > index.html",
      "sudo echo $private_ip >> index.html",
      "sudo mv index.html  /var/www/html/",
  ]

  #bastion_host_ip= publicInstance_publicip[0]

}

module "alb-all" {
  source = "./LoadBalancer"

  privatealb-name = "private-alb"

  publicalb-name = "public-alb"

#   count = 2
#   publicInstance_sg_id = module.Instances[count.index].publicSG

  publicSubnetsALB = module.myNetwork.publicSubnet_id

  privateSubnetsALB = module.myNetwork.privateSubnet_id

  VPC-ID-FOR-LB = module.myNetwork.vpc-id

  public_instance_id = module.Instances[*].PublicInstances_id

  private_instance_id = module.Instances[*].PrivateInstances_id

}