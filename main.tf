
resource "tls_private_key" "pvtkey" {
    algorithm = "RSA"
    rsa_bits = 4096
     
}

resource "local_sensitive_file" "id_rsa" {
    filename = "./id_rsa"
    content = "${tls_private_key.pvtkey.private_key_pem}"
  
}

resource "local_file" "id_rsa_pub" {
    filename = "./id_rsa_pub"
    content = tls_private_key.pvtkey.public_key_openssh
  
}


#Create a new key pair
resource "aws_key_pair" "terraform_kp" {
  key_name   = "terraform_kp"
  public_key = local_file.id_rsa_pub.content
}


# Create EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-08978028fd061067a" # Specify your desired AMI ID
  instance_type = "t2.medium"             # Specify your desired instance type
  key_name      = "terraform_kp"          # Specify your existing key pair name

  tags = {
    Name = "web-instance"
  }

#Configure security group with ports 22 (SSH) and 80 (HTTP) open
  security_groups = ["terraform-new-security-group"]
}

#Create security group with ports
resource "aws_security_group" "terraform_new_sg" {
  name        = "terraform-new-security-group"
  description = "Allow SSH and HTTP inbound traffic"
  
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


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
 
}