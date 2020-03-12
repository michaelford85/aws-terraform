provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "tls_private_key" "mford-terraform-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.mford-terraform-key.public_key_openssh}"
}


resource "aws_instance" "example" {
  count         = 5
  ami           = "ami-0a887e401f7654935"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"

  tags = {
    Name  = "Terraform-${count.index + 1}"
    demo  = "terraform-ansible"
  }
}
