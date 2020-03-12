provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "tls_private_key" "mford-terraform-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-aws-key"
  public_key = "${tls_private_key.mford-terraform-key.public_key_openssh}"
}


resource "aws_vpc" "terraform_vpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "Terraform VPC"
    demo  = "terraform-ansible"
  }
}

resource "aws_subnet" "terraform_subnet" {
  vpc_id            = "${aws_vpc.terraform_vpc.id}"
  cidr_block        = "192.168.0.0/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Terraform Subnet"
    demo  = "terraform-ansible"
  }
}


resource "aws_instance" "example" {
  count         = 5
  ami           = "ami-0a887e401f7654935"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  subnet_id     = "${aws_subnet.terraform_subnet.id}"


  tags = {
    Name  = "Terraform-${count.index + 1}"
    demo  = "terraform-ansible"
  }
}

resource "local_file" "foo" {
    content          = "${tls_private_key.mford-terraform-key.private_key_pem}"
    filename         = "/tmp/terraform-aws-key.pem"
    file_permission  = "0600"
}
