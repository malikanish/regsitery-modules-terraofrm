vpc_name        = "anish-prod-vpc"
aws_region      = "us-east-1"
environment     = "production"
vpc_cidr        = "10.20.0.0/16"
public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnets = ["10.20.101.0/24", "10.20.102.0/24"]
igw_name        = "anish-internet-gateway"
natgw_name      = "anish-nat-gateway"

# #EC2-Module
# instance_name     = "anish-ec2"
key_name      = "anishhhh-key"
instance_type = "t2.micro"

sg_name  = "Anish-sg"
ALb_name = "Anish-alb"

Asg_name             = "Anish-asg"
launch_template_name = "anish-asg-instance"

ecs_container_image = "nginx"
