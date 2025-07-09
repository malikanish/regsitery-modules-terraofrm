variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]
}

variable "public_cidr_blocks" {
  type    = list(string)
  default = [] 
}

variable "sg_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

# variable "cidr_blocks" {
#   type = list(string)
#   description = "List of CIDR blocks (e.g. public subnet CIDRs) to allow traffic from"
# }
