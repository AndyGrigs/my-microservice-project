# Lesson 7 — Kubernetes + Helm on AWS

## Опис проєкту
Kubernetes кластер (EKS) з Django додатком, розгорнутим через Helm.

## Інфраструктура
- **VPC** — приватна мережа з двома публічними підмережами
- **ECR** — Docker registry для зберігання образу Django
- **EKS** — Kubernetes кластер з двома нодами t3.medium
- **S3 + DynamoDB** — зберігання Terraform state

## Вимоги
- Terraform >= 1.0
- AWS CLI >= 2.0
- kubectl
- Helm >= 3.0
- Docker

## Розгортання інфраструктури

### 1. Ініціалізація Terraform
```bash
terraform init
```

### 2. Створення інфраструктури
```bash
terraform apply
```

### 3. Підключення kubectl до кластера
```bash
aws eks update-kubeconfig --region eu-central-1 --name django-cluster
```

### 4. Перевірка нод
```bash
kubectl get nodes
```

## Завантаження Docker образу в ECR

### 1. Збірка образу
```bash
docker build -t django-app:latest .
```

### 2. Авторизація в ECR
```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <ECR_URL>
```

### 3. Тегування та push
```bash
docker tag django-app:latest <ECR_URL>/django-app:latest
docker push <ECR_URL>/django-app:latest
```

## Розгортання через Helm

### Встановлення
```bash
helm install django-release ./charts/django-app
```

### Оновлення
```bash
helm upgrade django-release ./charts/django-app
```

### Перевірка
```bash
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl get configmap
```

## Структура Helm chart
- `deployment.yaml` — розгортання Django подів
- `service.yaml` — LoadBalancer для зовнішнього доступу
- `configmap.yaml` — змінні середовища
- `hpa.yaml` — автомасштабування від 2 до 6 подів при CPU > 70%

## Результати
Після розгортання Django доступний за публічною адресою LoadBalancer:
```
http://a950391029dc5490d81896221008e22c-1968945320.eu-central-1.elb.amazonaws.com/
```