provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "key"
  public_key = file("key.pub")
}

resource "aws_instance" "ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = "ami-0278fe6949f6b1a06"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }

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

