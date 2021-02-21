# Pull AZ's
data "aws_availability_zones" "available" {
  state = "available"
}
