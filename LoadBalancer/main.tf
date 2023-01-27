resource "aws_lb" "PublicALB" {
  name               = var.publicalb-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PublicALB_sg.id]
  subnets            = var.publicSubnetsALB 
  #[for subnet in var.publicSubnetsALB : subnet.id]

}
resource "aws_lb_target_group" "PublicalbTG" {
  name     = "PublicalbTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.VPC-ID-FOR-LB
}

resource "aws_lb_target_group_attachment" "TGaPublic" {
  count = length(var.private_instance_id)
  target_group_arn = aws_lb_target_group.PublicalbTG.arn
  target_id        = var.public_instance_id[count.index].id
  #var.public_instance_id
  #[for instance in var.public_instance_id : instance.id]
  port             = 80
}

resource "aws_lb_listener" "PublicLBlistener" {
  load_balancer_arn = aws_lb.PublicALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PublicalbTG.arn
  }
}

resource "aws_lb" "PrivateALB" {
  name               = var.privatealb-name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.privateALB_sg.id]
  subnets            = var.privateSubnetsALB
  #[for subnet in var.privateSubnetsALB : subnet.id]

}

resource "aws_lb_target_group" "privatealbTG" {
  name     = "privatealbTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.VPC-ID-FOR-LB
}

resource "aws_lb_target_group_attachment" "TGaPrivate" {
  count = length(var.private_instance_id)
  target_group_arn = aws_lb_target_group.privatealbTG.arn
  target_id        = var.private_instance_id[count.index].id
  # var.private_instance_id 
  #[for instance in var.private_instance_id : instance.id]
  port             = 80
}

resource "aws_lb_listener" "PrivateLBlistener" {
  load_balancer_arn = aws_lb.PrivateALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.privatealbTG.arn
  }
}

resource "aws_security_group" "PublicALB_sg" {
  name        = "PublicALB_sg"
  description = "allow ssh on 22 & http on port 80"
  vpc_id      = var.VPC-ID-FOR-LB

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

resource "aws_security_group" "privateALB_sg" {
  name        = "privateALB_sg"
  description = "allow ssh on 22 & http on port 80 "
  vpc_id      = var.VPC-ID-FOR-LB

  ingress {
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    #security_groups = [for instance in flatten(var.publicInstance_sg_id): instance.id]
    #source_security_group_id = [var.publicInstance_sg_id[0]]
    cidr_blocks = ["0.0.0.0/0"]

  }
 

  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    #security_groups = [for instance in flatten(var.publicInstance_sg_id): instance.id]
    #source_security_group_id = [var.publicInstance_sg_id[0]]
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

