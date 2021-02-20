resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_classiclink   = "false"

  tags = merge(
    local.common_tags,
    map(
      "Name", "${var.stack_name} VPC"
    )
  )
}

# Create /23 subnets for DMZ networks
resource "aws_subnet" "public_subnets" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${cidrsubnet(local.dmzNet, 2, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names["${count.index}"]}"
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    map(
      "Name", "${var.environment}-PublicAZ${count.index + 1}"
    )
  )
}

# Create /21 subnets for App networks
resource "aws_subnet" "private_subnets" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${cidrsubnet(local.vpcNet, 2, count.index + 1)}"
  availability_zone       = "${data.aws_availability_zones.available.names["${count.index}"]}"
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    map(
      "Name", "${var.environment}-PrivateAZ${count.index + 1}"
    )
  )
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    map(
      "Name", "Default GW for ${var.environment} VPC"
    )
  )
}

# default route table
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = merge(
    local.common_tags,
    map(
      "Name", "Default RT. DO NOT USE."
    )
  )
}

# public route tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "RT for PublicAZs",
      "Net", "Public"
    )
  )
}

# NAT EIPs
resource "aws_eip" "nat_eip" {
  count = var.az_count
  vpc   = true

  tags = merge(
    local.common_tags,
    map(
      "Name", "EIP for Gateway Nat in ${element(aws_subnet.private_subnets.*.availability_zone, count.index)}",
    )
  )
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  count         = var.az_count
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)

  tags = merge(
    local.common_tags,
    map(
      "Name", "Gateway Nat for ${element(aws_subnet.private_subnets.*.availability_zone, count.index)}",
    )
  )
}

# private route tables
resource "aws_route_table" "private_rt" {
  count  = length(aws_nat_gateway.nat_gw)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "RT for PrivateAZs",
      "Net", "Private"
    )
  )
}

# private subnet route table associations
resource "aws_route_table_association" "private_rta" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
}

# public subnet route table associations
resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}
