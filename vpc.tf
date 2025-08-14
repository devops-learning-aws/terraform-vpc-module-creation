resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames =var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
    Name = local.resource_name
  }
  )
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
     {
    Name = "${local.resource_name}"
  }
  )
 
}

resource "aws_subnet" "public_subnet" {
  count=length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone =local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_cidrs_tags,
     {
      Name = "${local.resource_name}-public-${local.az_names}"
  }
  )
 
}
resource "aws_subnet" "private_subnet" {
  count=length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone =local.az_names[count.index]


  tags = merge(
    var.common_tags,
    var.public_subnet_cidrs_tags,
     {
      Name = "${local.resource_name}-private-${local.az_names[count.index]}"
  }
  )
 
}
resource "aws_subnet" "database_subnet" {
  count=length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone =local.az_names[count.index]


  tags = merge(
    var.common_tags,
    var.database_subnet_cidrs_tags,
     {
      Name = "${local.resource_name}-database-${local.az_names[count.index]}"
  }
  )
 
}
resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.data_subnet[*].id

  tags = merge(
    var.common_tags,
    var.data_subnet_group_tags,
     {
    Name = "${local.resource_name}"
  }
  )
 
}

resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id #we have to choose natgate way one subnet so here i have choosed 0 index subnet
  tags = merge(
    var.common_tags,
    var.ngw_tags,
    {
    Name = "${local_resource_name}"
  }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
     {
    Name = "${local.resource_name}-public"}
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
     {
    Name = "${local.resource_name}-private"}
  )
}

resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
     {
    Name = "${local.resource_name}-database"}
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet[*].id,count.index)
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnet[*].id,count.index)
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.data_subnet[*].id,count.index)
  route_table_id = aws_route_table.database_route_table.id
}