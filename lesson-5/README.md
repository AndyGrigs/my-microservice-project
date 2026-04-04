# Lesson 5 — Terraform Modules

Проєкт демонструє організацію інфраструктури AWS за допомогою модулів Terraform.
Інфраструктура включає remote state на S3, мережу VPC та репозиторій контейнерів ECR.

## Структура проєкту

```
lesson-5/
│
├── main.tf          # Головний файл — підключення всіх модулів
├── backend.tf       # Налаштування бекенду S3 + DynamoDB для стейтів
├── outputs.tf       # Загальні вихідні дані з усіх модулів
│
├── modules/
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB таблиці
│   │   ├── variables.tf     # Змінні модуля
│   │   └── outputs.tf       # URL бакета та ім'я DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # VPC, підмережі, IGW, NAT Gateway
│   │   ├── routes.tf        # Route Tables та асоціації
│   │   ├── variables.tf     # Змінні модуля
│   │   └── outputs.tf       # ID VPC, підмереж, шлюзів
│   │
│   └── ecr/                 # Модуль для ECR
│       ├── ecr.tf           # Репозиторій, політика доступу, lifecycle
│       ├── variables.tf     # Змінні модуля
│       └── outputs.tf       # URL репозиторію ECR
│
└── README.md
```

---

## Команди

### Ініціалізація

```bash
terraform init
```

Завантажує провайдери та ініціалізує модулі. Виконується один раз перед першим запуском.

### Перевірка плану

```bash
terraform plan
```

Показує які ресурси будуть створені, змінені або видалені — без реального застосування.

### Застосування

```bash
terraform apply
```

Створює або оновлює інфраструктуру відповідно до конфігурації.

### Видалення

```bash
terraform destroy
```

Видаляє всі ресурси, створені Terraform.

---

## Порядок першого деплою

> S3-бакет має бути створений **до** активації `backend.tf`.

**Крок 1** — закоментуй вміст `backend.tf`, ініціалізуй з локальним стейтом:

```bash
terraform init
terraform apply -target=module.s3_backend
```

**Крок 2** — розкоментуй `backend.tf`, перенеси стейт в S3:

```bash
terraform init -migrate-state
```

**Крок 3** — задеплой решту інфраструктури:

```bash
terraform apply
```

---

## Опис модулів

### `s3-backend`

Створює інфраструктуру для зберігання Terraform state.

| Ресурс | Опис |
|---|---|
| `aws_s3_bucket` | Бакет для зберігання стейт-файлів |
| `aws_s3_bucket_versioning` | Версіювання — зберігає історію стейтів |
| `aws_s3_bucket_server_side_encryption_configuration` | Шифрування AES256 |
| `aws_s3_bucket_public_access_block` | Блокування публічного доступу |
| `aws_dynamodb_table` | Таблиця для блокування стейту (LockID) |

Вхідні змінні: `bucket_name`, `table_name`

---

### `vpc`

Створює повну мережеву інфраструктуру.

| Ресурс | Опис |
|---|---|
| `aws_vpc` | VPC з підтримкою DNS |
| `aws_subnet` (public x3) | Публічні підмережі в 3 зонах доступності |
| `aws_subnet` (private x3) | Приватні підмережі в 3 зонах доступності |
| `aws_internet_gateway` | IGW для виходу публічних підмереж в інтернет |
| `aws_eip` + `aws_nat_gateway` | NAT Gateway для виходу приватних підмереж |
| `aws_route_table` (public) | Маршрут `0.0.0.0/0` → Internet Gateway |
| `aws_route_table` (private) | Маршрут `0.0.0.0/0` → NAT Gateway |

Вхідні змінні: `vpc_cidr_block`, `public_subnets`, `private_subnets`, `availability_zones`, `vpc_name`

---

### `ecr`

Створює репозиторій Docker-образів у AWS.

| Ресурс | Опис |
|---|---|
| `aws_ecr_repository` | Репозиторій з автоматичним скануванням образів (`scan_on_push`) |
| `aws_ecr_repository_policy` | Політика доступу для поточного AWS акаунта (push/pull) |
| `aws_ecr_lifecycle_policy` | Зберігає останні 10 образів, старіші видаляються |

Вхідні змінні: `ecr_name`, `scan_on_push`
