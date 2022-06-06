provider "aws" {
  region     = "eu-north-1"
}

# Create vpc
resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test-vpc.id


}

# Create Custom Route Table
resource "aws_route_table" "test-route-table" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Test"
  }
}

# Create Subnet 
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1c"

  tags = {
    Name = "test-subnet"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.test-route-table.id
}

# Create Security Group to allow port 22
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_traffic"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    description = "SSH"
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
    Name = "allow_ssh"
  }
}

# Create a network interface with an ip in the subnet 
resource "aws_network_interface" "unbound-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_ssh.id]

}

# Assign an elastic IP to the network interface
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.unbound-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}




