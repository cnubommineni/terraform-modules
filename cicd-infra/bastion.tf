
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-security-group"
  description = "Used for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "eks_bastion" {

  ami           = var.bastion_image_id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = var.jump_pem_key_name
  //security_groups = [aws_security_group.bastion_sg.name]
  //vpc_security_group_ids = [aws_security_group.bastion_sg.name]
}
