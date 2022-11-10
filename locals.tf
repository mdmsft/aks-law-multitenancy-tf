locals {
  resource_suffix = "${var.project}-${var.environment}-${var.region}"
  context_name    = "${var.project}-${var.environment}"
}
