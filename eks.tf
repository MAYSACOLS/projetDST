module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = var.cluster_name
  create_iam_role = true

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
  
#Auto scaling
  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = var.key_name # Replace with your key pair name
       tags = {
        Name = "PW_eks_node_group"
      }
    }
  }
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = { # by default, only https urls can be reached from inside the cluster
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

# Profile Fargate pour gérer automatiquement l'infrastructure des clusters
module "fargate_profile" {
  source = "terraform-aws-modules/eks/aws//modules/fargate-profile"

  cluster_name = module.eks.cluster_name
  subnet_ids   = module.vpc.private_subnets
  name         = "fargate-profile"

  selectors = [
    {
      namespace = "staging"
    }
  ]
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
