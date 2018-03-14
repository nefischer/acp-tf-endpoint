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
 *        subnet_tags     = {
 *          "SubnetType" = "public"
 *        }
 *      }
 *
 */

# Get the host zone id
data "aws_route53_zone" "selected" {
  count = "${dns_zone != "" ? 1 : 0}"
  name  = "${var.dns_zone}."
}

# Get a list of the subnets to attach to
data "aws_subnet_ids" "selected" {
  tags   = "${var.subnet_tags}"
  vpc_id = "${var.vpc_id}"
}

## Create the security group for the endpoint
resource "aws_security_group" "filter" {
  description = "The security group for endpoint service: ${var.service_name}"
  name        = "${var.security_group_name ? format("%s-endpoint", var.name) : var.security_group_name}"
  tags        = "${merge(var.tags, map("Endpoint", var.service_name))}"
  vpc_id      = "${var.vpc_id}"
}

## Add the security group rules for the endpoint
resource "aws_security_group_rule" "ingress" {
  count = "${length(var.ingress)}"

  type              = "ingress"
  from_port         = "${lookup(var.ingress[count.index], "port")}"
  to_port           = "${lookup(var.ingress[count.index], "port")}"
  protocol          = "tcp"
  cidr_blocks       = ["${lookup(var.ingress[count.index], "cidr")}"]
  security_group_id = "${aws_security_group.filter.id}"
}

## Create the endpoint
resource "aws_vpc_endpoint" "endpoint" {
  security_group_ids = ["aws_security_group.filter.id"]
  service_name       = "${var.service_name}"
  subnet_ids         = "${aws_subnet_ids.selected.ids}"
  vpc_endpoint_typ   = "Interface"
  vpc_id             = "${var.vpc_id}"
}

## Create a DNS entry for this NLB
resource "aws_route53_record" "dns" {
  count = "${dns_zone != "" ? 1 : 0 }"

  zone_id = "${data.aws_route53_zone.selected.id}"
  name    = "${var.dns_name == "" ? var.name : var.dns_name}"
  type    = "${var.dns_type}"
  ttl     = "${var.dns_ttl}"
  records = ["${aws_vpc_endpoint.dns_entry.dns_name}"]
}