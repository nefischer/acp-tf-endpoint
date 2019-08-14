/**
 * Module usage:
 *
 *      module "endpoint" {
 *        source         = "git::https://github.com/UKHomeOffice/acp-tf-endpoint?ref=master"
 *
 *        name            = "my-service"
 *        service_name    = "com.amazonaws.vpce.eu-west-2.vpce-svc-2382383928392382"
 *        dns_zone        = "example.com"
 *        ingress = [
 *          {
 *             "cidr" = "0.0.0.0/0"
 *             "port" = "6001"
 *          },
 *        ]
 *        subnet_ids     = [ "subnet-323829832", "subnet-32382122" ]
 *      }
 *
 */
terraform {
  required_version = ">= 0.12"
}

# Get the host zone id
data "aws_route53_zone" "selected" {
  count = var.dns_zone == "" ? 0 : 1

  name         = var.dns_zone
  private_zone = var.dns_private
}

## Create the security group for the endpoint
resource "aws_security_group" "filter" {
  description = "The security group for endpoint service: ${var.service_name}"
  name        = var.security_group_name == "" ? format("%s-endpoint", var.name) : var.security_group_name

  tags = merge(
    var.security_tags,
    {
      "Name" = var.security_group_name == "" ? format("%s-endpoint", var.name) : var.security_group_name
    },
    {
      "Endpoint" = var.service_name
    },
  )

  vpc_id = var.vpc_id
}

## Add the security group ingress rules
resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress)

  type              = "ingress"
  from_port         = var.ingress[count.index]["port"]
  to_port           = var.ingress[count.index]["port"]
  protocol          = var.ingress[count.index]["protocol"]
  cidr_blocks       = [var.ingress[count.index]["cidr"]]
  security_group_id = aws_security_group.filter.id
}

## Add the security group egress rules
resource "aws_security_group_rule" "egress" {
  count = length(var.egress)

  type              = "egress"
  from_port         = var.egress[count.index]["port"]
  to_port           = var.egress[count.index]["port"]
  protocol          = var.egress[count.index]["protocol"]
  cidr_blocks       = [var.egress[count.index]["cidr"]]
  security_group_id = aws_security_group.filter.id
}

## Create the endpoint
resource "aws_vpc_endpoint" "endpoint" {
  security_group_ids = [aws_security_group.filter.id]
  service_name       = var.service_name
  subnet_ids         = var.subnet_ids
  vpc_endpoint_type  = "Interface"
  vpc_id             = var.vpc_id
}

## Create a DNS entry for this NLB
resource "aws_route53_record" "dns" {
  count = var.dns_zone != "" ? 1 : 0

  zone_id = data.aws_route53_zone.selected[0].id
  name    = var.dns_name == "" ? var.name : var.dns_name
  type    = var.dns_type
  ttl     = var.dns_ttl
  records = [aws_vpc_endpoint.endpoint.dns_entry[0]["dns_name"]]
}
