resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Allow selected ports only for public CIDR blocks"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(flatten([
      for cidr in var.public_cidr_blocks : [
        for port in var.allowed_ports : {
          cidr = cidr
          port = port
        }
      ]
    ]))

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
      description = "Allow port ${ingress.value.port} from public subnet"
    }
  }

  dynamic "ingress" {
    for_each = toset(var.public_cidr_blocks)
    content {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = [ingress.value]
      description = "Allow Ping (ICMP)"
    }
  }

  # Egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = var.tags
}
