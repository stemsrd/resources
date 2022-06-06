# Create EC2 t3.micro instance from amazon linux ami

resource "aws_instance" "unbound-server" {
  ami               = "ami-08bdc08970fcbd34a"
  iam_instance_profile = aws_iam_instance_profile.unbound.name
  instance_type     = "t3.micro"
  availability_zone = "eu-north-1c"
  key_name          = "new-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.unbound-server-nic.id
  }

  tags = {
    Name = "unbound-server"
  }

# call ansible to setup instance
  provisioner "remote-exec" {
    inline = ["echo hello"]
    }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(pathexpand("~/.aws/new-key.pem"))
    }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ~/.aws/new-key.pem -i '${aws_instance.unbound-server.public_ip},' unbound_setup.yml"
  }

}

# store the cloudwatch configuration in the AWS Systems Manager Parameter Store
resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "cloudwatch-config"
  type        = "String"
  value       = file("cloudwatch_config.json")
}


output "server_private_ip" {
  value = aws_instance.unbound-server.private_ip

}

output "server_id" {
  value = aws_instance.unbound-server.id
}
