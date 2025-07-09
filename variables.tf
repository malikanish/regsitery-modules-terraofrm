variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "my-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "igw_name" {
  type = string
}

variable "natgw_name" {
  type = string
}



variable "key_name" {
  description = "EC2 instance ka SSH key pair name"
  type        = string
}

# variable "security_group_id" {
#   description = "VPC security group ID jo EC2 ke sath lagani hai"
#   type        = string
# }

# variable "subnet_id" {
#   description = "Subnet ID jismein EC2 instance create karna hai"
#   type        = string
# }


variable "instance_type" {
  type = string

}

variable "sg_name" {
  type = string

}

variable "ALb_name" {
  type = string

}

variable "Asg_name" {
  type = string

}
variable "launch_template_name" {
  description = "Name tag for EC2 instances launched by Launch Template"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
  default     = "anish-ecs-cluster"
}

variable "ecs_task_family" {
  description = "Family name of the ECS Task Definition"
  type        = string
  default     = "anish-task"
}

variable "ecs_container_name" {
  description = "Container name"
  type        = string
  default     = "anish-app"
}

variable "ecs_container_image" {
  description = "Docker image for container"
  type        = string
  default     = "nginx"
}

variable "ecs_container_port" {
  description = "Port on which container listens"
  type        = number
  default     = 80
}



# variable "aws_region" {
#   type    = string
#   default = "us-east-1"
# }
# variable "vpc_name" {
#   type    = string
#   default = "my-vpc"
# }
# variable "vpc_cidr" {
#   type    = string
#   default = "10.0.0.0/16"
# }
# variable "public_subnets" {
#   type = list(string)
# }
# variable "private_subnets" {
#   type = list(string)
# }
# variable "environment" {
#   type    = string
#   default = "dev"
# }
# variable "igw_name" {
#   type = string
# }
# variable "natgw_name" {
#   type = string
# }
# variable "key_name" {
#   description = "EC2 instance ka SSH key pair name"
#   type        = string
# }
# # variable "security_group_id" {
# #   description = "VPC security group ID jo EC2 ke sath lagani hai"
# #   type        = string
# # }
# # variable "subnet_id" {
# #   description = "Subnet ID jismein EC2 instance create karna hai"
# #   type        = string
# # }
# variable "instance_type" {
#   type = string
# }
# variable "sg_name" {
#   type = string
# }
# variable "ALb_name" {
#   type = string
# }
# variable "Asg_name" {
#   type = string
# }
# variable "launch_template_name" {
#   description = "Name tag for EC2 instances launched by Launch Template"
#   type        = string
# }
# variable "ecs_cluster_name" {
#   type    = string
#   default = "my-ecs-cluster"
# }
