resource "aws_vpc" "main" {
    cidr_block       = var.cidr_block
    enable_dns_hostnames = var.enable_dns_hostnames
    instance_tenancy = "default"

    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.resource_name
    }
  )
}

# expense-dev-public-us-east-1a
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_name[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
        Name= "${local.resource_name}-public-${local.az_name[count.index]}"
    }
  )
}

# expense-dev-private-us-east-1a
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_name[count.index]

    tags = merge (
        var.common_tags,
        var.private_subnet_tags,
        {
            Name = "${local.resource_name}-private-${local.az_name[count.index]}"
        }
    )
}

# expense-dev-private-us-east-1a 

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_name[count.index]

    tags = merge(
        var.common_tags,
        var.database_subnet_tags,
        {
            Name = "${local.resource_name}-database-${local.az_name[count.index]}"
        }
    )
}

 resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (
    var.common_tags,
    var.nat_tags,
    {
        Name = local.resource_name
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
} 

#expense-dev-public
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        var.public_route_table_tags,
        {
            Name = "${local.resource_name}-public"
        }
    )
}


resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = var.destination_cidr_block
    gateway_id = aws_internet_gateway.igw.id
}

#expense-dev-private

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    route {
    cidr_block = var.destination_cidr_block
    nat_gateway_id = aws_nat_gateway.example.id
  }
    tags = merge (
        var.common_tags,
        var.private_route_table_tags,
        {
            Name = "${local.resource_name}-private"
        }
    )
}

#expense-dev-database

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = var.destination_cidr_block
        nat_gateway_id = aws_nat_gateway.example.id
    }

    tags = merge (
        var.common_tags,
        var.database_route_table_tags,
        {
            Name = "${local.resource_name}-database"
        }
    )
}

/* resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.foo.id
  route_table_id = aws_route_table.bar.id
} */

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidrs)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
}