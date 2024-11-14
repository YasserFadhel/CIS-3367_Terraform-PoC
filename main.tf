# Terraform configuration and fetch AWS as a provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

# Define the AWS provider and specify the region (we chose us-east-1)
provider "aws" {
  region = "us-east-1"
}

# Fetch the latest Amazon Linux 2 AMI for us-east-1
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# VPC configuration
# This creates a new Virtual Private Cloud (VPC) with a /16 CIDR block named main-vpc
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Web subnet configuration
# This subnet is used for the web tier (public) and is placed in the first availability zone (We are doing only 1 zone for this proof of concept, but we can specify mutiple AZ for actual project).
resource "aws_subnet" "web_subnet" {
  vpc_id            = aws_vpc.main_vpc.id               # Variable that gets the id of the VPC created above
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true                        # Enables public IP assignment for instances

  tags = {
    Name = "web-subnet"
  }
}

# Database subnet configuration
# This subnet is used for the database tier and is placed in the first availability zone.
resource "aws_subnet" "db_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "db-subnet"
  }
}

resource "aws_subnet" "db_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "db-subnet-b"
  }
}

# Internet Gateway configuration
# Allows instances in the VPC to access the internet.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Route table configuration for the web subnet
# Defines a route for internet traffic to go through the Internet Gateway.
resource "aws_route_table" "web_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the route table with the web subnet
resource "aws_route_table_association" "web_route_assoc" {
  subnet_id      = aws_subnet.web_subnet.id
  route_table_id = aws_route_table.web_route_table.id
}

# Security group for the web tier
# Allows HTTP (port 80) and SSH (port 22) traffic from any IP address.
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
    Name = "web-sg"
  }
}

# Security group for the database tier
# Allows MySQL (port 3306) traffic only from the web subnet. We'll use this to manipulate the RDS content later on.
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress { #Inbound Traffic
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.web_subnet.cidr_block]
  }

  egress { #Outbound Traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# EC2 instance for the web server
# Uses a free-tier eligible Amazon Linux 2 AMI and attaches it to the web subnet.
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.web_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = true                                         # Ensure a public IP is assigned

  tags = {
    Name = "web-server"
  }
}

# RDS MySQL database instance
# Configures a free-tier eligible RDS instance for MySQL.
resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = "admin"
  password               = "password1234"
  db_subnet_group_name   = aws_db_subnet_group.main.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false
}

# Database subnet group
# Groups the database subnet for use by the RDS instance.
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet.id, aws_subnet.db_subnet_b.id] # Added `db_subnet_b`

  tags = {
    Name = "main-db-subnet-group"
  }
}

# S3 bucket configuration for object storage
# Creates an S3 bucket for storing application documents securely.
resource "aws_s3_bucket" "app_bucket" {
  bucket = "gogreen-insurance-docs-us-east-1"
  tags = {
    Name = "app-bucket"
  }
}

# Output the public IP of the web server, RDS endpoint, and S3 bucket name (Makes my life easier!)
output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.id
}