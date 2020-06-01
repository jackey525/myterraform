# myterraform
terraform 學習

# Configure AWS CLI

For this tutorial, you will need to have AWS CLI installed. The official guide could be found [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

After AWS CLI is installed, you need to configure it! First, create a new [access keys](https://console.aws.amazon.com/iam/home?#/security_credentials). Now, in your terminal run aws configure, and enter your credentials. It will allow Terraform AWS provider to access AWS API.

# Create EC2

It is time for the fun part! Create a new directory. Inside, create a file with arbitrary name, but tf extension, and the following content:

```
provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "key"
  public_key = file("key.pub")
}

resource "aws_instance" "ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = "ami-03ba3948f6c37a4b0"
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


```

The best part about Terraform, people familiar with AWS, can guess all the created resources by looking at the file! We are going to create EC2 T2 Micro instance with AMI 03ba3948f6c37a4b0, new security group allowing inbound traffic on port 22, for SSH, new SSH key pair, and associate, and allocate Elastic IP for our instance. 

Notice, that I am using a local key pair. The keys should be located in the same folder as your Terraform file, and be named keys.pub, and keys. You can change your key location value, or even hardcode the key directly in your program.

I advice you to generate a new key, specifically for this tutorial! On Linux machine it could be done using ssh-keygen:

```
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/dev/.ssh/id_rsa): key
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in key.
Your public key has been saved in key.pub.
The key fingerprint is:
SHA256:K+5CJqeyyfx/Wlwg0yb9P3mJd+nqyQu/cHq8bLO+0J4 dev@pop-os
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|      o          |
|     + =         |
|      = o        |
|        So       |
|  . + . ... + . .|
|   *  .o.  O.* o |
|+.. ...o    #==  |
|o=...==    .=EO. |
+----[SHA256]-----+
```
設定權限
```
chmod 400 key*
```

開始執行 初始化
```
terraform init
```
開始建置 provision EC2
```
terraform apply -auto-approve
```
刪除剛剛建立的所有 服務
```
terraform destroy
```

.gitignore檔案裡面 記得加上
```
.terraform
*.tfstate
*.tfstate.backup
```
# EC2會建置一個 Elastic IP 彈性 IP

只要滿足以下條件，彈性 IP 地址便不會產生費用：

    彈性 IP 地址與 EC2 實例關聯。
    與彈性 IP 地址關聯的實例正在運行。
    該實例只附加有一個彈性 IP 地址。

# ssh-agent forwarding 透過 Bastion跳板主機 登入 EC2 instance
Local —(SSH)—> Server1 —(SSH)—> Server2

不要把 public key 放進去跳板主機內 ，key 都是放在 自己的 電腦上

```
$ ssh-add 自己的key
//外部 跳板主機
$ ssh -A user@server 
內部ㄧ樣，key 已經帶著
$ ssh -A user@server
```
