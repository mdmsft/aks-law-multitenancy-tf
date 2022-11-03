resource "random_string" "project" {
  length  = 8
  special = false
  numeric = false
  upper   = false
}

locals {
  project         = random_string.project.result
  resource_suffix = "${local.project}-${var.environment}-${var.region}"
  context_name    = "${local.project}-${var.environment}"
  common_suffix   = "${var.environment}-${var.region}"
  namespaces = {
    "red"    = uuidv5("x500", "CN=red")
    "orange" = uuidv5("x500", "CN=orange")
    "yellow" = uuidv5("x500", "CN=yellow")
    "green"  = uuidv5("x500", "CN=green")
    "blue"   = uuidv5("x500", "CN=blue")
    "indigo" = uuidv5("x500", "CN=indigo")
    "violet" = uuidv5("x500", "CN=indigo")
  }
}
