variable "cidr_block" {

}

variable "enable_dns_hostnames" {
    default = "true"
}


variable "project_name" {

}

variable "environment" {

}

variable "common_tags" {
    type = map
}

variable "vpc_tags" {

    default = {}

}

variable "igw_tags" {
    default = {}
}

variable "public_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.public_subnet_cidrs) == 2
        error_message = "please provide 2 valid subnet cidr's"
    }
}

variable "public_subnet_tags" {
    default = {}
}

variable "private_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.private_subnet_cidrs) == 2
        error_message = "please provide 2 valid private subnet cidr's"
    }
}

variable "private_subnet_tags" {
    default = {}
}

variable "database_subnet_cidrs" {
    type = list 
    validation {
        condition = length(var.database_subnet_cidrs) == 2
        error_message = "please provide valid 2 database subnet cidr's"
    }
}

variable "database_subnet_tags" {
    default = {}
}

variable "nat_tags" {
    default = {}
}

variable "public_route_table_tags" {
    default = {}

}

variable "private_route_table_tags" {
    default = {}
}

variable "database_route_table_tags" {
    default = {}
}

variable "destination_cidr_block" {
    default = "0.0.0.0/0"
}

variable "is_peering_required" {
    default = false
}

variable "peer_tags" {
    default = {}
}