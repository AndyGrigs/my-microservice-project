module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name         = "django-cicd-terraform-state-andy-grigs"   # те саме ім'я що в backend.tf!
  dynamodb_table_name = "terraform-locks"
  aws_region          = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "django-app"
  project_name    = var.project_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = "${var.project_name}-cluster"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids  # worker nodes у private!
  node_instance_type = "t3.medium"
  desired_nodes      = 2
  min_nodes          = 1
  max_nodes          = 4

  depends_on = [module.vpc]
}

module "jenkins" {
  source = "./modules/jenkins"

  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca             = module.eks.cluster_certificate_authority_data
  ecr_repository_url     = module.ecr.repository_url
  aws_region             = var.aws_region
  jenkins_admin_password = var.jenkins_admin_password
  git_repo_url           = var.git_repo_url

  depends_on = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  project_name  = var.project_name
  environment   = var.environment
  use_aurora    = var.rds_use_aurora

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  family         = var.rds_family
  instance_class = var.rds_instance_class

  db_name     = var.rds_db_name
  db_username = var.rds_db_username
  db_password = var.rds_db_password

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  depends_on = [module.vpc]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca             = module.eks.cluster_certificate_authority_data
  git_repo_url           = var.git_repo_url
  app_namespace          = "django-app"
  grafana_admin_password = var.grafana_admin_password

  depends_on = [module.eks]
}
