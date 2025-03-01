provider "aws" {
  region = "ap-northeast-1"
}

variable "server_port" {
  description = "HTTPサーバポート"
  type = number
  default = 8080
}

resource "aws_launch_template" "example" {
    name_prefix = "terraform-template-example"
    image_id = "ami-0a290015b99140cd1"
    instance_type = "t2.micro"

    network_interfaces {
        associate_public_ip_address = true 
        security_groups = [aws_security_group.instance.id]
    }

    user_data = base64encode(<<-EOF
                #!/bin/bash
                echo "Hello, World4" > index.html
                nohup busybox httpd -f -p ${var.server_port} &

                # ログ出力
                ps aux | grep busybox > /var/log/userdata.log
                netstat -tulnp | grep LISTEN >> /var/log/userdata.log
                EOF
                )
}

resource "aws_autoscaling_group" "example" {
    launch_template {
        id = aws_launch_template.example.id
        version = "$Latest"
    }

    min_size = 2
    max_size = 10
    desired_capacity = 2

    # vpc_zone_identifier = ["subnet-0838f49bbd9a27b63"]
    vpc_zone_identifier = data.aws_subnets.default.ids

    tag {
        key = "Name"
        value = "terrafrom-asg-example"
        propagate_at_launch = true
    }
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

data "aws_vpc" "default" {
    filter {
        name = "tag:Name"
        values = ["default-vpc"]
    }
}

data "aws_subnets" "default" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default.id]
    }
    filter {
        name = "map-public-ip-on-launch"
        values = ["true"]
    }
}