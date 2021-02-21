locals {
  common_tags = {
    managed_by_terraform = "true"
    stack_name           = var.stack_name
    environment          = var.environment
    platform             = var.platform
  }
}
