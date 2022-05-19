prefix = "devops-ninja"
cidr_block = "10.0.0.0/16"
zones_quantity = 1
subnet_cidr_blocks = ["10.0.0.0/24"]
ami_id = "ami-0c4f7023847b90238"
key_name = "ec2-devops-ninja"
instance_type = "t2.large"
instances_names = ["manager", "k8s-1", "k8s-2", "k8s-3"]