provider "aws" {
  region = "ap-northeast-1"
}

# resource "aws_instance" "example" {
#   ami = "ami-0a290015b99140cd1"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = ["sg-0d521f12d384465dd"] 
#   subnet_id = "subnet-0a14e2a0f2e4b5879"
#   tags = {
#     Name = "kenteru_testa"
#   }
# }

variable "server_port" {
  description = "HTTPサーバポート"
  type = number
  default = 8080
}

output "public_ip" {
    value = aws_instance.example.public_ip
    description = "EC2のパブリックIPアドレス"
}

resource "aws_instance" "example" {
    ami = "ami-0a290015b99140cd1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    associate_public_ip_address = true

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World2" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }
    subnet_id = "subnet-0838f49bbd9a27b63"
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    vpc_id = "vpc-001b3338c91d11f0c"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}