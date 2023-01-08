resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}

resource "aws_security_group" "sg" {
  name        = "allow-ports"
  vpc_id      = aws_vpc.main.id

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "sg"
  }
}



resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.main.id
  #private_ips = ["10.0.1.10"]
  security_groups = [aws_security_group.sg.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-0b93ce03dcbcb10f6" # us-east-1
  #ami           = "ami-026b57f3c383c2eec"
  instance_type = "t2.micro"
  key_name = "myownkey"
  user_data = templatefile("/user_data/user_data.tpl",{
        key = local.key
  }
  )
  tags = {
    Name = "myat"
  }

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }
  

}



output "public_ip" {
  value = aws_instance.foo.public_ip
}

output "gg" {
  value = local.key
}

resource "local_file" "ip" {
    content = aws_instance.foo.public_ip
    filename = "ip.txt"
}

resource "null_resource" "remote_ansible" {
    depends_on = [aws_instance.foo]
    connection {
      type = "ssh"
      user = "root"
      host = "192.168.1.30"
    }

  provisioner "file" {
    source = "ip.txt"
    destination  = "/etc/ansible/awshost"
}

  provisioner "remote-exec" {
   inline = [
   "cd /etc/ansible",
   "sudo ansible-playbook -i awshost playbook/initial_setup.yml"
]
}
}

