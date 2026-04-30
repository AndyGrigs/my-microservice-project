# Module: rds

Universal module that creates either a standard RDS instance or an Aurora Cluster depending on the `use_aurora` variable.

## Resources created

| Resource | Always | Only RDS | Only Aurora |
|---|---|---|---|
| `aws_db_subnet_group` | ✅ | | |
| `aws_security_group` | ✅ | | |
| `aws_db_parameter_group` | | ✅ | |
| `aws_rds_cluster_parameter_group` | | | ✅ |
| `aws_db_instance` | | ✅ | |
| `aws_rds_cluster` | | | ✅ |
| `aws_rds_cluster_instance` (writer) | | | ✅ |

---

## Usage

### Standard PostgreSQL RDS instance

```hcl
module "rds" {
  source = "./modules/rds"

  project_name  = "django-cicd"
  environment   = "production"
  use_aurora    = false

  engine         = "postgres"
  engine_version = "15.4"
  family         = "postgres15"
  instance_class = "db.t3.medium"
  multi_az       = false

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = var.rds_db_password

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

### Aurora PostgreSQL Cluster

```hcl
module "rds" {
  source = "./modules/rds"

  project_name  = "django-cicd"
  environment   = "production"
  use_aurora    = true

  engine         = "aurora-postgresql"
  engine_version = "15.4"
  family         = "aurora-postgresql15"
  instance_class = "db.r6g.large"

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = var.rds_db_password

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

### Aurora MySQL Cluster

```hcl
module "rds" {
  source = "./modules/rds"

  project_name  = "django-cicd"
  environment   = "production"
  use_aurora    = true

  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.04.0"
  family         = "aurora-mysql8.0"
  instance_class = "db.r6g.large"

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = var.rds_db_password

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

---

## Variables

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `project_name` | `string` | — | ✅ | Project name used for naming and tagging all resources |
| `environment` | `string` | `"production"` | | Environment name (e.g. staging, production) |
| `use_aurora` | `bool` | `false` | | `true` → Aurora Cluster + writer. `false` → single `aws_db_instance` |
| `engine` | `string` | `"postgres"` | | DB engine: `postgres`, `mysql`, `aurora-postgresql`, `aurora-mysql` |
| `engine_version` | `string` | `"15.4"` | | Engine version. Must match the chosen engine |
| `family` | `string` | `"postgres15"` | | Parameter group family. Must match engine and version |
| `instance_class` | `string` | `"db.t3.medium"` | | Instance type. Use `db.r6g.*` for production Aurora |
| `allocated_storage` | `number` | `20` | | Storage in GB — ignored when `use_aurora = true` |
| `multi_az` | `bool` | `false` | | Multi-AZ standby replica — ignored when `use_aurora = true` |
| `db_name` | `string` | `"appdb"` | | Name of the initial database to create |
| `db_username` | `string` | `"dbadmin"` | | Master username |
| `db_password` | `string` | — | ✅ | Master password — mark as `sensitive` in tfvars |
| `vpc_id` | `string` | — | ✅ | ID of the VPC for the security group |
| `subnet_ids` | `list(string)` | — | ✅ | Private subnet IDs for the DB Subnet Group (min 2, different AZs) |
| `allowed_cidr_blocks` | `list(string)` | `["10.0.0.0/8"]` | | CIDR blocks allowed to reach the DB port |

---

## Outputs

| Name | Description |
|---|---|
| `endpoint` | Connection host — writer endpoint for Aurora, address for RDS |
| `port` | DB port (5432 for PostgreSQL, 3306 for MySQL) — derived automatically |
| `db_name` | Name of the initial database |
| `security_group_id` | ID of the RDS security group |
| `subnet_group_name` | Name of the DB subnet group |
| `cluster_id` | Aurora cluster identifier — empty string when `use_aurora = false` |
| `instance_id` | RDS instance identifier — empty string when `use_aurora = true` |

---

## How to change configuration

### Switch from RDS to Aurora

Change a single variable:

```hcl
use_aurora    = true
engine        = "aurora-postgresql"
family        = "aurora-postgresql15"
instance_class = "db.r6g.large"   # Aurora works best on memory-optimised classes
```

> `allocated_storage` and `multi_az` are ignored for Aurora — remove them to keep the config clean.

### Change the DB engine

| Engine | `engine` | `engine_version` | `family` |
|---|---|---|---|
| PostgreSQL 15 | `postgres` | `15.4` | `postgres15` |
| PostgreSQL 14 | `postgres` | `14.10` | `postgres14` |
| MySQL 8 | `mysql` | `8.0.35` | `mysql8.0` |
| Aurora PostgreSQL 15 | `aurora-postgresql` | `15.4` | `aurora-postgresql15` |
| Aurora MySQL 8 | `aurora-mysql` | `8.0.mysql_aurora.3.04.0` | `aurora-mysql8.0` |

### Change the instance class

```hcl
# Dev / test
instance_class = "db.t3.micro"

# Standard production
instance_class = "db.t3.medium"

# Aurora production (memory-optimised)
instance_class = "db.r6g.large"
```

### Enable Multi-AZ (RDS only)

```hcl
use_aurora = false
multi_az   = true
```

### Restrict DB access to specific subnets only

```hcl
allowed_cidr_blocks = ["10.0.10.0/24", "10.0.11.0/24"]  # only private subnets
```
