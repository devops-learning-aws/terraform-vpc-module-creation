output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  
  value = aws_internet_gateway.gw.id
}
output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}
output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}
output "database_subnet_id" {
  value = aws_subnet.database_subnet[*].id
}
output "data_subnet_group_name" {
    value = aws_db_subnet_group.default.name
  
}
output "epi_id" {
  value = aws_eip.nat.id
}