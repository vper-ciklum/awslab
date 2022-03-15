

// EC2 Instances: Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type - ami-023c8dbf8268fb3ca
// Storage size: 8GB (Default)
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "description"
    values = ["Amazon Linux AMI 2018.03.0* x86_64 HVM ebs"]
  }
}

// Configure the EC2 for Webserver
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

  tags = {
    "Name" = "${var.namespace}-webserver"
  }

  # Upload the ssh key file to EC2
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ec2-user/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  
  // Change access for the ssh key
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }

}

// Configure the EC2 for Database
resource "aws_instance" "ec2_private" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[0]
  vpc_security_group_ids      = [var.sg_priv_id]

  tags = {
    "Name" = "${var.namespace}-database"
  }

}