module "vpc" {
    source = "./modules/vpc"
    prefix = var.prefix
    cidr_block = var.cidr_block
    zones_quantity = var.zones_quantity
    subnet_cidr_blocks = var.subnet_cidr_blocks
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "devops-ninja"
  description = "Security group for devops-ninja"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/16"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["one", "two", "three", "four"])

  name = "instance-${each.key}"

  ami                    = "ami-0022f774911c1d690"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  monitoring             = false
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id              = module.vpc.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}