provider "aws" {
    region="us-east-2"
}

#create vpc
resource "aws_vpc" "huma-application-deployment"{
    cidr_block = "10.2.0.0/16"
    
    tags = {
        Name = "huma-application-deployment-vpc"
    }
}

resource "aws_internet_gateway" "huma-ig" {
    vpc_id = "${aws_vpc.huma-application-deployment.id}"

    tags = {
        Name = "huma-ig"
    }
}

resource "aws_route_table" "huma-rt" {
    vpc_id = "${aws_vpc.huma-application-deployment.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.huma-ig.id}"
    }
}

module "db-tier" {
    name = "huma-database"
    source = "./modules/db-tier"
    vpc_id = "${aws_vpc.huma-application-deployment.id}"
    route_table_id = "${aws_vpc.huma-application-deployment.main_route_table_id}"
    cidr_block = "10.2.0.0/24"
    user_data = templatefile("./scripts/db_user_data.sh",{})
    ami_id = "ami-0a2fa7d546310e467"
    map_public_ip_on_launch = false

    ingress = [{
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = "${module.application-tier.subnet_cidr_block}"
    }]
}

module "application-tier" {
    name = "huma-app"
    source = "./modules/application-tier"
    vpc_id = "${aws_vpc.huma-application-deployment.id}"
    route_table_id = "${aws_route_table.huma-rt.id}"
    cidr_block = "10.2.1.0/24"
    user_data=templatefile("./scripts/app_user_data.sh",{mongodb_ip=module.db-tier.private_ip})
    ami_id= "ami-0316f230821b1a544"
    map_public_ip_on_launch=true

    ingress = [{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "86.25.54.140/32"
    },
    {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "3.22.81.46/32"
}]
}