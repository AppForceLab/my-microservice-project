# Мій власний мікросервісний проєкт  
Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".  

## Мета  
Навчитися основам роботи з DevOps інструментами та практиками розгортання застосунків через повний цикл розробки та доставки програмного забезпечення.

## Структура проєкту

- **lesson-3/**: Bash скрипти для встановлення інструментів розробки
- **lesson-4/**: Django застосунок з Docker та docker-compose
- **lesson-5/**: Terraform інфраструктура на AWS (VPC, ECR, S3 backend)
- **lesson-7/**: Kubernetes EKS з Helm для розгортання Django застосунку
- **lesson-8-9/**: Повний CI/CD pipeline з Jenkins, Terraform, ECR, Helm та Argo CD

## Урок 8-9 - Повний CI/CD з Jenkins + Terraform + ECR + Helm + Argo CD 🚀

### Опис проєкту
Цей урок демонструє реалізацію повного CI/CD pipeline'у, який об'єднує Jenkins, Terraform, Amazon ECR, Helm та Argo CD для автоматичного розгортання Django-застосунку без ручного втручання.

### Архітектура CI/CD

```
[Django App Code] 
    ↓ (git push)
[Jenkins Pipeline]
    ↓ (build & push)
[Amazon ECR]
    ↓ (update values.yaml)
[Git Repository]
    ↓ (git push)
[Argo CD]
    ↓ (sync)
[EKS Cluster] → [Django App]
```

### Компоненти Infrastructure (Terraform):
- **EKS Cluster**: Kubernetes кластер версії 1.28 з 2 worker nodes
- **VPC**: Virtual Private Cloud з публічними та приватними підмережами
- **ECR**: Elastic Container Registry для зберігання Docker образів
- **Jenkins**: CI/CD сервер, встановлений через Helm
- **Argo CD**: GitOps deployment tool, встановлений через Helm

### CI/CD Pipeline:
1. **Jenkins Pipeline**: Збирає Docker образ, пушить до ECR, оновлює Helm chart
2. **Argo CD**: Автоматично синхронізує зміни з Git репозиторію до Kubernetes

### Результати розгортання ✅

**Створені ресурси AWS:**
- ✅ EKS Cluster: `lesson-8-9-eks-cluster`
- ✅ ECR Repository: `lesson-8-9-ecr`
- ✅ VPC з публічними та приватними підмережами
- ✅ S3 bucket для Terraform state
- ✅ DynamoDB таблиця для блокувань

**Kubernetes ресурси:**
- ✅ Jenkins: Namespace `jenkins` з LoadBalancer service
- ✅ Argo CD: Namespace `argocd` з LoadBalancer service  
- ✅ Django App: Deployment з автомасштабуванням

**CI/CD Workflow:**
- ✅ Автоматична збірка Docker образу з Kaniko
- ✅ Публікація в ECR з унікальними тегами (`build-number-git-hash`)
- ✅ Автоматичне оновлення Helm chart
- ✅ GitOps розгортання через Argo CD

### Команди для розгортання

```bash
# 1. Розгортання інфраструктури
cd lesson-8-9
terraform init
terraform apply

# 2. Налаштування kubectl
aws eks update-kubeconfig --region eu-west-1 --name lesson-8-9-eks-cluster

# 3. Отримання доступів
terraform output jenkins_url
terraform output jenkins_admin_password
terraform output argocd_url
terraform output argocd_admin_password

# 4. Очищення ресурсів для уникнення затрат
terraform destroy
```

## Урок 7 - Kubernetes EKS з Helm 🚀

### Опис проєкту
Розгортання Django-застосунку в Amazon EKS (Elastic Kubernetes Service) з використанням Terraform та Helm.

### Архітектура
- **EKS Cluster**: Kubernetes кластер версії 1.28 з 2 worker nodes
- **ECR**: Elastic Container Registry з Django образом
- **Helm Chart**: Для управління розгортанням застосунку
- **Load Balancer**: Для зовнішнього доступу
- **HPA**: Horizontal Pod Autoscaler для масштабування
- **ConfigMap**: Змінні оточення з lesson-4

### Результати розгортання ✅

**Створені ресурси AWS:**
- ✅ EKS Cluster: `lesson-7-eks-cluster`
- ✅ ECR Repository: `lesson-7-ecr` з Django образом
- ✅ VPC з публічними та приватними підмережами
- ✅ S3 backend для Terraform state

**Kubernetes ресурси:**
- ✅ Deployment: 2 реплік Django застосунку
- ✅ Service: LoadBalancer для зовнішнього доступу
- ✅ ConfigMap: 9 змінних оточення
- ✅ HPA: Автомасштабування від 2 до 6 подів при CPU > 70%

**Доступ до застосунку:**
```
URL: http://ac9cac65fa15d404a8d5f5e014141b3e-1810740142.eu-west-1.elb.amazonaws.com
Status: HTTP 200 OK
Server: gunicorn (Django додаток працює!)
```

### Структура проєкту lesson-7

```
lesson-7/
├── main.tf                  # Основна конфігурація
├── backend.tf               # S3 backend
├── outputs.tf               # Outputs
├── modules/
│   ├── eks/                 # EKS модуль
│   ├── ecr/                 # ECR модуль  
│   ├── vpc/                 # VPC модуль
│   └── s3-backend/          # S3 backend модуль
└── charts/
    └── django-app/          # Helm chart
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            ├── hpa.yaml
            └── _helpers.tpl
```

### Команди для розгортання

```bash
# 1. Розгортання інфраструктури
cd lesson-7
terraform init
terraform apply

# 2. Налаштування kubectl
aws eks update-kubeconfig --region eu-west-1 --name lesson-7-eks-cluster

# 3. Розгортання застосунку
helm install django-app ./charts/django-app

# 4. Перевірка стану
kubectl get all
```

## Урок 5 - Terraform інфраструктура на AWS

### Опис проєкту
Базова Terraform-структура для розгортання інфраструктури на AWS з використанням модульної архітектури.

### Ключові модулі
- **s3-backend**: S3 бакет та DynamoDB для Terraform state
- **vpc**: Мережева інфраструктура (VPC, підмережі, NAT Gateway)
- **ecr**: Elastic Container Registry для Docker образів

### Структура проєкту lesson-5

```
lesson-5/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів
├── outputs.tf               # Загальне виведення ресурсів
└── modules/
    ├── s3-backend/          # Модуль для S3 та DynamoDB
    ├── vpc/                 # Модуль для VPC
    └── ecr/                 # Модуль для ECR
```

## Урок 4 - Django з Docker

### Опис проєкту
Django веб-застосунок з PostgreSQL базою даних, упакований у Docker контейнери.

### Компоненти
- Django застосунок з Gunicorn
- PostgreSQL база даних
- Nginx як зворотний проксі
- Docker Compose для оркестрації

### Структура проєкту lesson-4

```
lesson-4/
├── Dockerfile               # Django контейнер
├── docker-compose.yml       # Оркестрація сервісів
├── requirements.txt         # Python залежності
├── manage.py               # Django управління
├── myproject/              # Django проєкт
└── nginx/                  # Nginx конфігурація
```

## Урок 3 - Інструменти розробки

### Опис проєкту
Bash скрипт для автоматичного встановлення інструментів розробки.

### Інструменти
- Docker та Docker Compose
- Python 3 та pip
- Django framework
- Додаткові утиліти для розробки

---

## Технології та інструменти

- **Хмарна платформа**: Amazon Web Services (AWS)
- **Інфраструктура як код**: Terraform
- **Контейнеризація**: Docker, Kaniko
- **Оркестрація**: Kubernetes (Amazon EKS)
- **Управління пакетами**: Helm
- **CI/CD**: Jenkins, Argo CD
- **GitOps**: Argo CD з автоматичною синхронізацією
- **Container Registry**: Amazon ECR
- **Веб-фреймворк**: Django
- **База даних**: PostgreSQL
- **Веб-сервер**: Nginx, Gunicorn

### Еволюція проєкту:
- **Урок 3**: Інструменти розробки (Docker, Python, Django)
- **Урок 4**: Контейнеризація застосунку (Django + Docker + docker-compose)
- **Урок 5**: Infrastructure as Code (Terraform modules на AWS)
- **Урок 7**: Kubernetes оркестрація (EKS + Helm + Django deployment)
- **Урок 8-9**: Повний CI/CD automation (Jenkins + Argo CD + GitOps)

## Автор
Проєкт виконаний в рамках курсу DevOps CI/CD