variable "environment" {
  type        = string
  description = "The environment type being created. Eg: prod, test, etc"
}

variable "platform" {
  type        = string
  default     = "amp"
  description = "Product name. Eg: prod, test, etc"
}

variable "region" {
  type    = string
  description = "The AWS region VPC being created. Eg: us-east-2, us-west-2, etc"
}

variable "stack_name" {
  type    = string
  description = "Terraform stack name. Eg: prod-vpc, test-vpc, etc"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC. If Prod VPC:10.76.0.0/16, then us-east-2:10.76.0.0/19, us-west-2:10.76.32.0/19 etc"
  type        = string
}

variable "az_count" {
  default     = 3
  description = "Number of AZ's to use"
}

variable "enable_dns_hostnames" {
  default = "false"
}
# variable "public_subnet_cidr_blocks" {
#   description = "The list of CIDR blocks to use in building the public subnets. List size needs to match availability zone count"
#   type        = list
# }

# variable "private_subnet_cidr_blocks" {
#   description = "The list of CIDR blocks to use in building the private subnets. List size needs to match availability zone count"
# }

# variable "availability_zones" {
#   description = "The list of availability zone to utilize in a given region"
#   type        = list
# }
