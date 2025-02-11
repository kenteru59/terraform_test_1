provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "example" {
  ami = "ami-0a290015b99140cd1"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-0d521f12d384465dd"] 
  subnet_id = "subnet-0a14e2a0f2e4b5879"
  tags = {
    Name = "kenteru_testa"
  }
}