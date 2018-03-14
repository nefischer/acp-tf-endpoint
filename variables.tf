variable "dns_name" {
  description = "An optional override for the dns name to use, defaults to var.name"
  default     = ""
}

variable "dns_ttl" {
  description = "The dns time-to-live for the dns alias record"
  default     = "300"
}

variable "dns_private" {
  description = "Indicates the route53 domain is private"
  default     = true
}

variable "dns_type" {
  description = "The dns record type we should use for the alias"
  default     = "CNAME"
}

variable "dns_zone" {
  description = "The domain of a route53 domain you wish to add a cname to"
  default     = ""
}

variable "ingress" {
  description = "An array of map of ingress rules for the security group"

  default = [
    {
      cidr = "0.0.0.0/0"
      port = "-1"
    },
  ]
}

variable "name" {
  description = "A descriptive name for the endpoint you can consuming"
}

variable "security_group_name" {
  description = "An optional override to the security group name of the endpoint"
  default     = ""
}

variable "service_name" {
  description = "The private link endpoint service you wish to consumer"
}

variable "security_tags" {
  description = "A map of additional tags you can add to the security group tags"
  default     = {}
}

variable "subnet_tags" {
  description = "A map of tags to match the subnets we should attach the endpoint"
  type        = "map"
}

variable "vpc_id" {
  description = "The VPC id you to adding the endpoint to"
}
