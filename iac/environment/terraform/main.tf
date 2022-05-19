module "vpc" {
  source             = "./modules/vpc"
  prefix             = var.prefix
  cidr_block         = var.cidr_block
  zones_quantity     = var.zones_quantity
  subnet_cidr_blocks = var.subnet_cidr_blocks
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "devops-ninja"
  description = "Security group for devops-ninja"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-8080-tcp", "https-443-tcp", "ssh-tcp", "all-tcp"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(var.instances_names)

  name = each.key

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = false
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id              = module.vpc.subnet_id

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "${each.key}-root-block"
        Terraform   = "true"
        Environment = "dev"
      }
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
