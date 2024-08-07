module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "PW1-vpc"
  cidr = "10.0.0.0/16"

  azs = data.aws_availability_zones.available.names

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
    database_subnet_tags = {
    "Name" = "database-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Role" = "database"
  }
}
#Configuration du Groupe de Sous-réseaux RDS
resource "aws_db_subnet_group" "mariadb_subnet_group" {
  name       = "mariadb-subnet-group"
  subnet_ids = var.database_subnets

  tags = {
    Name = "mariadb-subnet-group"
  }
}