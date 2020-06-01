
provider "aws" {
  profile = "default"
  region = var.region
  # AWS provider 2.0 以上的版本皆可
  version = "~> 2.0"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "key"
  public_key = file("key.pub")
}

data "aws_ami" "target_ami" {
  most_recent = true

  owners  = ["self"]

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }
}

resource "aws_instance" "ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = data.aws_ami.target_ami.id
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }
  vpc_security_group_ids = [
      "${aws_security_group.allow_tls.id}"
    ]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key")
    host        = self.public_ip
  }

}

resource "aws_security_group" "allow_tls" {
  name        = "allow_ssh"
  description = "Allow SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.ubuntu.id
}

output "bastion_public_ip" {
  value = "${aws_instance.ubuntu.public_ip}"
}

