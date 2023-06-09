provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app" {
  ami           = "ami-0806bc468ce3a22ec"
  instance_type = "t2.micro"
  subnet_id     = "subnet-02107dcc77c5746f5"
  vpc_security_group_ids = ["sg-08ba0abbbd57ef070"]
  key_name      = "key"

  tags = {
    Name = "app"
  }
}


resource "aws_ecr_repository" "app_repo" {
  name = "app"
}

resource "aws_ecr_repository" "db_repo" {
  name = "db"
}
