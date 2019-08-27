Module usage:

     module "endpoint" {
       source         = "git::https://github.com/UKHomeOffice/acp-tf-endpoint?ref=master"

       name            = "my-service"
       service_name    = "com.amazonaws.vpce.eu-west-2.vpce-svc-2382383928392382"
       dns_zone        = "example.com"
       ingress = [
         {
            "cidr" = "0.0.0.0/0"
            "port" = "6001"
         },
       ]
       subnet_id     = [ "subnet-323829832", "subnet-32382122" ]
     }



## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| dns_name | An optional override for the dns name to use, defaults to var.name | `` | no |
| dns_private | Indicates the route53 domain is private | `true` | no |
| dns_ttl | The dns time-to-live for the dns alias record | `300` | no |
| dns_type | The dns record type we should use for the alias | `CNAME` | no |
| dns_zone | The domain of a route53 domain you wish to add a cname to | `` | no |
| egress | An array of map of egress rules for the security group | `<list>` | no |
| ingress | An array of map of ingress rules for the security group | `<list>` | no |
| name | A descriptive name for the endpoint you can consuming | - | yes |
| security_group_name | An optional override to the security group name of the endpoint | `` | no |
| service_name | The private link endpoint service you wish to consumer | - | yes |
| subnet_ids | A collection of subnet id which the endpoints should be connected to (only valid for endpoints of type Interface) | - | yes |
| vpc_id | The VPC id you to adding the endpoint to | - | yes |
| vpc_endpoint_type | The type of endpoint (Intefrace or Gateway) | `Interface` | no |
| route_table_ids | A collection of route tables routing traffic to the endpoints (only valid for endpoints of type Gateway) | `[]` | no |
