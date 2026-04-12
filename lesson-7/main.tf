provider "aws" {
  region = "eu-central-1"
}

module "s3_backend" {
  source              = "./modules/s3-backend"
  bucket_name         = "django-terraform-state-bucket-2024"
  dynamodb_table_name = "terraform-state-locks"
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "django-vpc"
  vpc_cidr             = "10.0.0.0/16"
  subnet_public_1_cidr = "10.0.1.0/24"
  subnet_public_2_cidr = "10.0.2.0/24"
  aws_region           = "eu-central-1"
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "django-app"
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "django-cluster"
  subnet_ids         = module.vpc.public_subnet_ids
  node_instance_type = "t3.medium"
}