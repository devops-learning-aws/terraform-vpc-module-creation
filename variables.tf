variable "project_name" {
    type = string
  
}
variable "environment_name" {
    type = string
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}
variable "common_tags" {
    type = map
  
}

variable "vpc_tags" {
    type = map
    default = {}
}
variable "enable_dns_hostnames" {
    type = bool
    default = true
  
}
variable "igw_tags" {
    type = map
    default = {}
  
}

variable "public_subnet_cidrs" {
    validation {
      condition = length(var.public_subnet) == 2
      error_message = "please provide two public subnet CIDRS"
    }
  
}
variable "public_subnet_cidrs_tags" {
    type = map
  default = {}
}
variable "private_subnet_cidrs" {
    validation {
      condition = length(var.private_subnet) == 2
      error_message = "please provide two private subnet CIDRS"
    }
  
}
variable "private_subnet_cidrs_tags" {
    type = map
    default = {}
}
variable "database_subnet_cidrs" {
    validation {
      condition = length(var.data_subnet) == 2
      error_message = "please provide two database subnet CIDRS"
    }
  
}
variable "database_subnet_cidrs_tags" {
    type = map
    default = {}
}
variable "data_subnet_group_tags" {
    type = map
     default = {}
}
variable "ngw_tags" {
    type = map
    default = {}
  
}
variable "public_route_table_tags" {
    type = map
    default = {}
  
}

variable "private_route_table_tags" {
    type = map
    default = {}
  
}
variable "database_route_table_tags" {
    type = map
    default = {}
  
}
