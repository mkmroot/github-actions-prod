# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# -----------------------------
# Public Subnet
# -----------------------------

# Public Subnet 1
resource "aws_subnet" "public_subnet_1" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = "10.0.10.0/24"

  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_subnet_2" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = "10.0.20.0/24"

  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# -----------------------------
# Route Table
# -----------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# -----------------------------
# Route Table Association
# -----------------------------
resource "aws_route_table_association" "rta1" {

  subnet_id = aws_subnet.public_subnet_1.id

  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rta2" {

  subnet_id = aws_subnet.public_subnet_2.id

  route_table_id = aws_route_table.public_rt.id
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "app_sg" {
  name        = "node-app-sg"
  description = "Allow SSH and App Port"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node App"
    from_port   = 3000
    to_port     = 3000
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
    Name = "node-app-sg"
  }
}

# -----------------------------
# Key Pair
# -----------------------------
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("id_rsa.pub")
}

# -----------------------------
# EC2 Instance
# -----------------------------
#resource "aws_instance" "app_server" {
#
#  ami           = "ami-0c02fb55956c7d316"
#  instance_type = var.instance_type
#
#  subnet_id = aws_subnet.public_subnet.id
#
#  vpc_security_group_ids = [
#    aws_security_group.app_sg.id
#  ]
#
#  key_name = aws_key_pair.deployer.key_name
#
#  associate_public_ip_address = true
#
#  tags = {
#    Name = "Node-App-Server"
#  }
#}
#
# -----------------------------
# ECR Repository
# -----------------------------
resource "aws_ecr_repository" "node_app_repo" {

  name = "node-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "node-app-repo"
  }
}
