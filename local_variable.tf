locals {
  key = "$my_ansible_public_key"
  user = "root"
  host = aws_instance.foo.public_ip
  ansible_node_ip = "192.168.1.30"
  remote_user = "root"
  ubuntu_ami = "ami-0b93ce03dcbcb10f6"
}
