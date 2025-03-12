resource "aws_vpc_peering_connection" "default" {
    count = var.is_peering_required ? 1 : 0
    vpc_id = aws_vpc.main.id # requestor
    peer_vpc_id = data.aws_vpc.default.id
    auto_accept = true

    tags = merge(
        var.common_tags,
        var.peer_tags,
        {
            Name = "${local.resource_name}-default"
        }
    )
}