



terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                     = data.aws_availability_zones.available.names
  public_subnets          = var.public_subnets
  private_subnets         = var.private_subnets
  map_public_ip_on_launch = true

  enable_nat_gateway = false
  single_nat_gateway = true

  igw_tags = {
    Name        = var.igw_name
    Environment = var.environment
  }

  nat_gateway_tags = {
    Name        = var.natgw_name
    Environment = var.environment
  }

  tags = {
    Environment = var.environment
    Project     = "MyProject"
  }
}

resource "aws_key_pair" "anish_key" {
  key_name   = "anishhhh-key"
  public_key = file("${pathexpand("~")}/Downloads/anishhhh-key.pub")
}

module "custom_sg" {
  source = "./modules/custom_sg"

  vpc_id        = module.vpc.vpc_id
  sg_name       = var.sg_name
  allowed_ports = [22, 80, 443]

  public_cidr_blocks = [
    "154.192.54.71/32",
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]

  tags = {
    Environment = var.environment
    Name        = var.sg_name
  }
}

module "alb_sg" {
  source        = "./modules/alb_sg"
  sg_name       = "alb-sg"
  vpc_id        = module.vpc.vpc_id
  allowed_ports = [80, 443]
  allowed_cidrs = ["0.0.0.0/0"]

  tags = {
    Name        = "alb-sg"
    Environment = var.environment
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.0"

  name               = var.ALb_name
  load_balancer_type = "application"

  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.public_subnets
  create_security_group = false
  security_groups       = [module.alb_sg.alb_sg_id]

  target_groups = [
    {
      name_prefix      = "anish-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        port                = "traffic-port"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Name        = var.ALb_name
    Environment = var.environment
  }
}
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "6.0.1"

  cluster_name                       = var.ecs_cluster_name
  default_capacity_provider_strategy = {}
  
  services = {
    myservice = {
      launch_type              = "EC2"
      network_mode             = "bridge"
      desired_count            = 1
      cpu                      = 256
      memory                   = 512
      requires_compatibilities = ["EC2"]

      container_definitions = {
        nginx = {
          name      = "nginx"
          image     = "${var.ecs_container_image}:latest"
          cpu       = 256
          memory    = 512
          essential = true
          portMappings = [
            {
              containerPort = 80
              hostPort      = 80
              protocol      = "tcp"
            }
          ]
  
          mountPoints = [
            {
              containerPath = "/var/cache/nginx"
              sourceVolume  = "nginx-cache"
              readOnly      = false
            },
            {
              containerPath = "/var/run"
              sourceVolume  = "nginx-run"
              readOnly      = false
            },
            {
              containerPath = "/tmp"
              sourceVolume  = "nginx-tmp"
              readOnly      = false
            }
          ]
    
          environment = [
            {
              name  = "NGINX_ENTRYPOINT_QUIET_LOGS"
              value = "1"
            }
          ]
          # logConfiguration = {
          #   logDriver = "awslogs"
          #   options = {
          #     "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          #     "awslogs-region"        = "us-east-1"
          #     "awslogs-stream-prefix" = "ecs"
          #   }
          # }
        }
      }

      volume = {
        nginx-cache = {
          name = "nginx-cache"
          host_path = "/tmp/nginx-cache"
        },
        nginx-run = {
          name = "nginx-run"
          host_path = "/tmp/nginx-run"
        },
        nginx-tmp = {
          name = "nginx-tmp"
          host_path = "/tmp/nginx-tmp"
        }
      }

      subnet_ids = module.vpc.public_subnets

      security_group_ingress_rules = {
        alb_ingress = {
          description                  = "Allow ALB to ECS"
          from_port                    = 80
          to_port                      = 80
          ip_protocol                  = "tcp"
          referenced_security_group_id = module.alb_sg.alb_sg_id
        }
      }

      security_group_egress_rules = {
        all_traffic = {
          description = "Allow all egress"
          from_port   = 0
          to_port     = 0
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_group_arns[0]
          container_name   = "nginx"
          container_port   = 80
        }
      }

      task_exec_iam_role_arn = module.ecs_task_execution_role.iam_role_arn
    }
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.7.0"

  name                = var.Asg_name
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = module.vpc.public_subnets

  create_launch_template = true
  launch_template_name   = "ecs-auto-asg"
  update_default_version = true

  image_id        = data.aws_ami.ecs_ami.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [module.custom_sg.security_group_id]

  create_iam_instance_profile = true
  iam_role_name               = "${var.Asg_name}-ec2-role"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    CloudWatchAgentServerPolicy         = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
set -xe

# Set ECS Cluster
echo "ECS_CLUSTER=${var.ecs_cluster_name}" > /etc/ecs/ecs.config

# Install Docker
yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# Required dirs for ECS agent
mkdir -p /etc/ecs /var/log/ecs /var/lib/ecs/data

# Create writable host volumes for nginx with proper permissions
mkdir -p /tmp/nginx-cache /tmp/nginx-run /tmp/nginx-tmp
chmod 755 /tmp/nginx-cache /tmp/nginx-run /tmp/nginx-tmp

# Set proper ownership - nginx container typically runs as user 101
chown -R 101:101 /tmp/nginx-cache /tmp/nginx-run /tmp/nginx-tmp

# Make sure directories are writable
chmod 777 /tmp/nginx-run /tmp/nginx-tmp

# Run ECS agent manually
docker run --name ecs-agent \
  --detach \
  --restart=on-failure:10 \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --volume=/var/log/ecs:/log \
  --volume=/var/lib/ecs/data:/data \
  --volume=/etc/ecs:/etc/ecs \
  --net=host \
  --env-file=/etc/ecs/ecs.config \
  amazon/amazon-ecs-agent:latest

sleep 30
docker logs ecs-agent | tail -n 30
EOF
  )

  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [module.alb.target_group_arns[0]]

  tags = {
    Name        = var.Asg_name
    Environment = var.environment
    Project     = "MyProject"
  }
}

module "ecs_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.34.0"

  role_name = "${var.ecs_cluster_name}-execution-role"

  create_role = true

  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}
