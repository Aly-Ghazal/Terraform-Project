data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "PublicEC2_sg" {
  description = "allow ssh on 22 & http on port 80"
  vpc_id      = var.vpc-id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Public_Ec2s_From_Terraform" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance-type
  #count         = 2
  subnet_id     = var.publicSubnet_id
  key_name      = "EC2 tutorial"

  vpc_security_group_ids = [aws_security_group.PublicEC2_sg.id]

  associate_public_ip_address = true
  # tags = {
  #   Name = var.publicInstances-tag-name[count.index]
  # }
  provisioner "local-exec" {
  command= "echo 'private IP is ${self.private_ip} & public IP is ${self.public_ip}' >> ./all-IPs.txt"
  }

  provisioner "remote-exec" {
    inline = var.public-inline

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("./EC2tutorial.pem")
      timeout     = "4m"
    }
  }


  
}


resource "aws_security_group" "PrivateEC2_sg" {
  description = "allow outbounds connections only"
  vpc_id      = var.vpc-id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #security_groups = [var.ALB_sg_id]
    #source_security_group_id = var.ALB_sg_id
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #source_security_group_id = var.ALB_sg_id
    #security_groups = [var.ALB_sg_id]
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "Private_Ec2s_From_Terraform" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance-type
  #count         = 2
  #subnet_id     = aws_subnet.privateSubnets[count.index].id
  subnet_id     = var.privateSubnet_id
  key_name      = "EC2 tutorial"
  vpc_security_group_ids = [aws_security_group.PrivateEC2_sg.id]
  
  provisioner "local-exec" {
  command= "echo 'private IP is ${self.private_ip}' >> ./all-IPs.txt"
  }

  provisioner "remote-exec" {
  inline = var.private-inline
  connection {
        type = "ssh"
        host =  self.private_ip
        user = "ubuntu"
        private_key = file("./EC2tutorial.pem")
        timeout     = "4m"

        bastion_host = aws_instance.Public_Ec2s_From_Terraform.public_ip
        #bastion_host_ip
        #aws_instance.Public_Ec2s_From_Terraform.public_ip
        bastion_user =   "ubuntu"
        bastion_host_key =  file("./EC2tutorial.pem")
      }
  }
  
  # tags = {
  #   Name = var.privateInstances-tag-name[count.index]
  # }
  

}