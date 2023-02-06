variable "vpc_id" {
    description = "The vpc ID in AWS"
}

variable "name" {
    description = "Name to be used for the Tags"
}

variable "route_table_id" {
    description = "The ID of the route table"
}

variable "cidr_block" {
    description = "The IP address"
}

variable "user_data" {
    description = "user data mentioned"
}

variable "ami_id" {
    description = "the id of the ami for the instance"
}

variable "map_public_ip_on_launch" {
    default = false
}

variable "ingress" {
    type = list
    description = "mentioning the ports and firewall"
}