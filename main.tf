resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a new key pair
resource "aws_key_pair" "example" {
  key_name   = "example-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Create a security group to allow inbound traffic on port 22
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Allow inbound traffic on port 22"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new instance
resource "aws_instance" "example" {
  ami           = "ami-07c8c1b18ca66bb07" # Replace with your actual AMI ID
  instance_type = "t3.micro"
  key_name      = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.example.id]
}

# Run a shell script on the instance
resource "null_resource" "example" {
  connection {
    type        = "ssh"
    host        = aws_instance.example.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.example.private_key_pem
  }
  
  provisioner "file" {
    source      = "/home/ubuntu/abc.sh"
    destination = "/home/ubuntu/abc.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/abc.sh",
      "/home/ubuntu/abc.sh"
    ]
  }
}
