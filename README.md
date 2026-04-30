# Django CI/CD — Jenkins + Helm + Terraform + Argo CD

Повний CI/CD pipeline для Django застосунку на AWS EKS із автоматичною синхронізацією через Argo CD.

---

## Архітектура CI/CD

```
Developer
    │
    │  git push
    ▼
GitHub (main branch)
    │
    │  webhook
    ▼
┌─────────────────────────────────┐
│           Jenkins               │
│  ┌─────────────────────────┐   │
│  │  Kaniko (build & push)  │   │
│  └────────────┬────────────┘   │
│               │                │
│  ┌────────────▼────────────┐   │
│  │  Git agent (update tag) │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
    │
    │  git push charts/django-app/values.yaml
    │  (tag: BUILD_NUMBER)
    ▼
GitHub (charts/django-app/values.yaml)
    │
    │  polling every 3 min
    ▼
┌─────────────────────────────────┐
│           Argo CD               │
│   detects values.yaml change    │
│   syncs Helm chart to cluster   │
└─────────────────────────────────┘
    │
    ▼
Amazon EKS (django-app namespace)
├── Deployment (gunicorn, 2-5 pods)
├── Service (ClusterIP)
├── ConfigMap (env vars)
├── HPA (cpu 70%)
└── Secret (DJANGO_SECRET_KEY)
```

---

## Інфраструктура (Terraform)

```
AWS
├── S3 + DynamoDB          — Terraform remote state
├── VPC
│   ├── Public Subnets     — NAT Gateway, Load Balancer
│   └── Private Subnets    — EKS Worker Nodes (без публічного IP)
├── ECR                    — Docker image registry
└── EKS
    ├── Jenkins (namespace: jenkins)
    └── Argo CD (namespace: argocd)
```

---

## Компоненти

| Компонент | Призначення |
|---|---|
| **Terraform** | Провізія AWS інфраструктури (VPC, EKS, ECR) |
| **Helm** | Встановлення Jenkins та Argo CD у кластер |
| **Jenkins + Kaniko** | Збірка Docker образу без Docker daemon |
| **Amazon ECR** | Зберігання Docker образів |
| **Argo CD** | GitOps синхронізація Helm chart у кластер |
| **Gunicorn** | Production WSGI сервер для Django |
| **HPA** | Автоскейлінг подів за CPU |

---

## Структура репозиторію

```
my-microservice-project/
├── Django/                  # Django застосунок
│   ├── app/                 # Вихідний код (manage.py, mysite/)
│   ├── Dockerfile           # gunicorn, python:3.11-slim
│   ├── Jenkinsfile          # CI pipeline (копія з кореня)
│   └── docker-compose.yaml  # Локальна розробка з PostgreSQL
├── charts/
│   └── django-app/          # Helm chart для деплою в EKS
│       ├── Chart.yaml
│       ├── values.yaml      # Jenkins оновлює image.tag тут
│       └── templates/
│           ├── deployment.yaml   # secretKeyRef для DJANGO_SECRET_KEY
│           ├── service.yaml
│           ├── configmap.yaml
│           ├── hpa.yaml         # Автомасштабування (CPU 70%)
│           └── secret.yaml      # DJANGO_SECRET_KEY (auto-generated)
├── modules/
│   ├── s3-backend/          # S3 + DynamoDB для Terraform state
│   ├── vpc/                 # VPC з private/public subnets + NAT
│   ├── ecr/                 # ECR репозиторій
│   ├── eks/                 # EKS кластер + EBS CSI driver
│   ├── rds/                 # PostgreSQL / Aurora RDS
│   ├── jenkins/             # Jenkins через Helm (Kaniko agent)
│   └── argo_cd/             # Argo CD + Prometheus + Grafana
│       └── charts/          # Helm-чарт для реєстрації Application
├── Jenkinsfile              # Pipeline: build → push → update git
├── main.tf
├── backend.tf               # S3 remote state
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── .gitignore
```

---

## Швидкий старт

### 1. Передумови

```bash
# Встанови необхідні інструменти
aws --version          # AWS CLI v2
terraform --version    # >= 1.5.0
helm version           # >= 3.0
kubectl version
```

### 2. Налаштуй AWS credentials

```bash
aws configure
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: eu-west-1
```

### 3. Створи S3 backend (перший раз — окремо)

```bash
cd modules/s3-backend
terraform init
terraform apply
```

> Після цього заповни `bucket` у `backend.tf` назвою створеного бакета.

### 4. Скопіюй та заповни змінні

```bash
cp terraform.tfvars.example terraform.tfvars
# Відредагуй terraform.tfvars — вкажи свої значення
```

### 5. Деплой інфраструктури

```bash
terraform init

# По черзі, з перевіркою
terraform apply -target=module.vpc
terraform apply -target=module.ecr
terraform apply -target=module.eks
terraform apply -target=module.jenkins
terraform apply -target=module.argo_cd
```

### 6. Налаштуй kubectl

```bash
# Команда з'явиться в outputs після terraform apply
aws eks update-kubeconfig --region eu-west-1 --name django-cicd-cluster
kubectl get nodes
```

### 7. Створи Kubernetes Secret для Django

```bash
kubectl create namespace django-app

kubectl create secret generic django-secrets \
  --from-literal=secret-key="$(openssl rand -base64 50)" \
  --namespace django-app

# Перевір
kubectl get secret django-secrets -n django-app
```

### 8. Отримай доступ до Jenkins

```bash
# Отримай пароль
kubectl get secret --namespace jenkins jenkins \
  -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode

# Відкрий UI (port-forward)
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
# → http://localhost:8080
```

### 9. Додай SSH ключ у Jenkins

```
Jenkins UI → Manage Jenkins → Credentials → System → Global
→ Add Credentials → SSH Username with private key
  ID: github-ssh-key
  Username: git
  Private Key: (встав вміст ~/.ssh/id_rsa)
```

### 10. Отримай доступ до Argo CD

```bash
# Отримай початковий пароль
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 --decode

# Отримай URL
kubectl get svc argocd-server -n argocd \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Або через port-forward
kubectl port-forward svc/argocd-server 8443:443 -n argocd
# → https://localhost:8443  (login: admin)
```

---

## Як працює повний цикл

```
1. Developer робить git push у main
2. GitHub webhook тригерить Jenkins pipeline
3. Jenkins (Kaniko) збирає Docker образ із django-app/Dockerfile
4. Образ публікується в ECR з тегом BUILD_NUMBER
5. Jenkins (git agent) клонує репо, оновлює image.tag у charts/django-app/values.yaml
6. Jenkins пушить зміни в main з повідомленням "ci: update image tag [skip ci]"
7. Argo CD (кожні 3 хв) виявляє зміни у values.yaml
8. Argo CD синхронізує Helm chart — робить rolling update деплойменту
9. Нові поди піднімаються з новим образом, старі завершуються
```

---

## Безпека

| Ризик | Рішення |
|---|---|
| Worker nodes з публічним IP | Private subnets для EKS node group |
| `DJANGO_SECRET_KEY` у Git | `secretKeyRef` → Kubernetes Secret |
| `manage.py runserver` у prod | `gunicorn` у CMD Dockerfile |
| Docker-in-Docker (privileged) | Kaniko — збірка без Docker daemon |
| ECR теги перезаписуються | `image_tag_mutability = "IMMUTABLE"` |
| S3 state публічний | `aws_s3_bucket_public_access_block` |
| Секрети у Terraform logs | `sensitive = true` для паролів |
| `terraform.tfvars` у Git | `.gitignore` блокує tfvars файли |

---

## Корисні команди

```bash
# Перевір стан Argo CD Application
kubectl get application -n argocd

# Форсова синхронізація
kubectl patch application django-app -n argocd \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'

# Переглянь поди Django
kubectl get pods -n django-app

# Логи пода
kubectl logs -f deployment/django-app -n django-app

# Перевір HPA
kubectl get hpa -n django-app

# Видали інфраструктуру
terraform destroy
```
