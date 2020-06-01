data "aws_vpc" "default" {
    default = true
}

resource "aws_route_table" "RT_private" {
    vpc_id = "${data.aws_vpc.default.id}"
    # tags {
    #     Name = "RT_private"
    # }
}

resource "aws_route_table_association" "RT_association_private" {
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id = "${aws_route_table.RT_private.id}"
}

resource "aws_subnet" "private_subnet" {
    # 172.31.0.0/16
    vpc_id            = "${data.aws_vpc.default.id}"
    availability_zone = "ap-northeast-1a"
    # 172.31.48.0/24`)
    cidr_block        = "${cidrsubnet(data.aws_vpc.default.cidr_block, 8, 48)}"
}


resource "aws_instance" "private_subnet_instance" {
    count         = "3"
    ami           = data.aws_ami.target_ami.id
    instance_type = "t2.micro"
    key_name      = "key"
    subnet_id     = "${aws_subnet.private_subnet.id}"
    vpc_security_group_ids = [
    "${aws_security_group.bastion_to_private.id}"
    ]
    # tags {
    #     Name = "private_subnet_instance_${count.index}"
    # }
}

resource "aws_security_group" "bastion_to_private" {
    name = "bastion_to_private"
    description = "ssh demo"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [
            "${aws_security_group.allow_tls.id}"
        ]
    }

    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [
            "${aws_security_group.allow_tls.id}"
        ]
    }
}