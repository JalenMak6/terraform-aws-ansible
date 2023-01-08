# terraform-aws-ansible

In this project, I am going to create a simple ec2 in AWS.

The ec2 will be under a VPC subnet with a public IP attached.

It will deployed and provisioned via Terraform.

After the instance is deployed, Terraform will trigger the Ansible playbook in my remote Ansible node and perform application  deploymenet.

For my playbook, you can check out my ansible repo and that's the playbook I am running
