locals {
  resource_name = "${var.project_name}-${var.environment}"
  az_name = slice(data.aws_availability_zones.available.names, 0, 2)
  default_vpc_id = data.aws_vpc.default.id
  default_vpc_cidr = data.aws_vpc.default.cidr_block
  default_route_table_id = data.aws_route_table.main.route_table_id
}
