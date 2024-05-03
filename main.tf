//le provider aws
provider "aws" {
  region     = var.aws_region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

// Générer une clé privée
resource "tls_private_key" "my_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Créer la paire de clés SSH dans AWS
resource "aws_key_pair" "my_keypair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.my_keypair.public_key_openssh
}

// Créer le groupe de sécurité
resource "aws_security_group" "websg" {
  name = "web-sg1"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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

  ingress {
    description = "siite"
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "server"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Créer l'instance EC2
resource "aws_instance" "terraform_vm" {
  ami                    = var.aws_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.websg.id]
  key_name               = aws_key_pair.my_keypair.key_name

  tags = {
    Name = var.instance_name
  }
}

// Se connecter à la VM et installer Docker
resource "null_resource" "connection" {
  connection {
    type        = "ssh"
    user        = var.vm_user
    private_key = tls_private_key.my_keypair.private_key_pem
    host        = aws_instance.terraform_vm.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mv /tmp/script.sh ./script.sh",
      "sudo apt-get update",
      "sudo apt-get install -y figlet",
      "figlet HERE",
      "ls -la",
      "chmod +x ./script.sh",
      "./script.sh"
    ]
  }

  depends_on = [aws_instance.terraform_vm]
}

// Sortie: adresse IP publique de l'instance EC2
output "instance_ips" {
  value = aws_instance.terraform_vm.public_ip
}
