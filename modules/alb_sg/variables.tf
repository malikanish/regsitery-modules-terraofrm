variable "vpc_id" {
  description = "VPC ID for the Security Group"
  type        = string
}

variable "sg_name" {
  description = "Name of the ALB security group"
  type        = string
}

variable "allowed_ports" {
  description = "List of ports to allow (e.g. [80, 443])"
  type        = list(number)
  default     = [80, 443]
}

variable "allowed_cidrs" {
  description = "CIDR blocks to allow traffic from"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Allow from anywhere by default
}

variable "tags" {
  description = "Tags to apply to the SG"
  type        = map(string)
  default     = {}
}
