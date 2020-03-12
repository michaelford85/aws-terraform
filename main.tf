provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  count         = 5
  ami           = "ami-0a887e401f7654935"
  instance_type = "t2.micro"
  key_name      = "terraform-demo-key"

  tags = {
    Name  = "Terraform-${count.index + 1}"
    demo  = "terraform-ansible"
  }
}
