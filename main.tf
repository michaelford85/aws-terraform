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

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags = {
    Name = "Terraform Internet Gateway"
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

resource "aws_route_table" "terraform_route_table" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags = {
    Name = "Terraform Route Table"
    demo  = "terraform-ansible"
  }
}

resource "aws_route" "outbound_route" {
  route_table_id            = "${aws_route_table.terraform_route_table.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.terraform_igw.id}"
}

resource "aws_security_group" "terraform_webserver_sg" {
  name        = "terraform_webserver_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.terraform_vpc.id}"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_webserver_sg"
    demo  = "terraform-ansible"
  }
}

resource "aws_instance" "example" {
  count         = 5
  ami           = "ami-0a887e401f7654935"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  subnet_id     = "${aws_subnet.terraform_subnet.id}"
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.terraform_webserver_sg.id}"]


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
