# Мій власний мікросервісний проєкт  
Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".  

## Мета  
Навчитися основам роботи з DevOps інструментами та практиками розгортання застосунків.

## Структура проєкту

- **lesson-3/**: Bash скрипти для встановлення інструментів розробки
- **lesson-4/**: Django застосунок з Docker та docker-compose
- **lesson-5/**: Terraform інфраструктура на AWS (VPC, ECR, S3 backend)
- **lesson-7/**: Kubernetes EKS з Helm для розгортання Django застосунку
- **lesson-db-module/**: Універсальний Terraform модуль для баз даних (RDS та Aurora)

## Lesson DB Module - Універсальний модуль баз даних 🗄️

### Опис проєкту
Універсальний Terraform модуль для розгортання баз даних на AWS, який підтримує як традиційні RDS інстанси, так і Aurora кластери.

### Ключові можливості
- **Подвійна підтримка**: RDS інстанси та Aurora кластери через прапор `use_aurora`
- **Багато двигунів**: PostgreSQL та MySQL для RDS і Aurora
- **Автоматичне створення**: DB Subnet Group, Security Group, Parameter Groups
- **Production-ready**: шифрування, бекапи, моніторинг, високої доступності

### Приклади використання модуля

**PostgreSQL RDS інстанс:**
```hcl
module "postgres_rds" {
  source = "./modules/rds"
  
  use_aurora     = false
  engine         = "postgres"
  engine_version = "14.18"
  instance_class = "db.t3.micro"
  
  db_name  = "myapp"
  username = "dbadmin"
  password = "MySecretPassword123!"
  
  vpc_id                        = module.vpc.vpc_id
  subnet_ids                   = module.vpc.private_subnet_ids
  allowed_security_group_ids   = [aws_security_group.app.id]
  
  environment   = "dev"
  project_name  = "lesson-db-module"
}
```

**Aurora MySQL кластер:**
```hcl
module "mysql_aurora" {
  source = "./modules/rds"
  
  use_aurora            = true
  engine               = "aurora-mysql"
  engine_version       = "8.0.mysql_aurora.3.02.0"
  aurora_instance_class = "db.r5.large"
  aurora_cluster_size   = 2
  
  db_name  = "webapp"
  username = "admin"
  password = "AuroraSecretPass123!"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  environment  = "production"
  project_name = "webapp"
}
```

### Опис змінних

**Обов'язкові змінні:**
- `password` - пароль для бази даних (sensitive)
- `vpc_id` - ID VPC для розгортання
- `subnet_ids` - список ID підмереж для DB subnet group

**Основні змінні конфігурації:**
- `use_aurora` - використовувати Aurora (true) чи RDS (false), за замовчуванням: `false`
- `engine` - двигун БД (postgres, mysql, aurora-mysql, aurora-postgresql), за замовчуванням: `postgres`
- `engine_version` - версія двигуна БД, за замовчуванням: `14.18`
- `instance_class` - клас інстансу для RDS, за замовчуванням: `db.t3.micro`
- `aurora_instance_class` - клас інстансу для Aurora, за замовчуванням: `db.r5.large`
- `db_name` - ім'я бази даних, за замовчуванням: `myapp`
- `username` - користувач БД, за замовчуванням: `dbadmin`

**Змінні продуктивності та безпеки:**
- `multi_az` - Multi-AZ розгортання, за замовчуванням: `false`
- `storage_encrypted` - шифрування зберігання, за замовчуванням: `true`
- `backup_retention_period` - період збереження бекапів (дні), за замовчуванням: `7`
- `deletion_protection` - захист від видалення, за замовчуванням: `false`
- `performance_insights_enabled` - увімкнути Performance Insights, за замовчуванням: `false`

### Як змінити тип БД, engine, клас інстансу

**Зміна типу БД (RDS ↔ Aurora):**
```hcl
# RDS інстанс
use_aurora = false
instance_class = "db.t3.micro"

# Aurora кластер
use_aurora = true
aurora_instance_class = "db.r5.large"
aurora_cluster_size = 2
```

**Зміна engine БД:**
```hcl
# PostgreSQL
engine = "postgres"
engine_version = "14.18"

# MySQL RDS
engine = "mysql" 
engine_version = "8.0.35"

# Aurora MySQL
engine = "aurora-mysql"
engine_version = "8.0.mysql_aurora.3.02.0"

# Aurora PostgreSQL
engine = "aurora-postgresql"
engine_version = "14.7"
```

**Зміна класу інстансу:**
```hcl
# Для розробки
instance_class = "db.t3.micro"           # RDS
aurora_instance_class = "db.t4g.medium"  # Aurora

# Для продакшена
instance_class = "db.r5.large"           # RDS
aurora_instance_class = "db.r5.xlarge"   # Aurora
```

**Налаштування продуктивності:**
```hcl
# Високі навантаження
allocated_storage = 500
max_allocated_storage = 1000
storage_type = "gp3"
multi_az = true
performance_insights_enabled = true
monitoring_interval = 60
```

### Результати розгортання ✅
- ✅ PostgreSQL RDS створено
- ✅ Endpoint: `lesson-db-module-dev-db.cdg82o4wqs1y.eu-west-1.rds.amazonaws.com:5432`
- ✅ Aurora PostgreSQL кластер успішно розгорнуто


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
- **Контейнеризація**: Docker
- **Оркестрація**: Kubernetes (Amazon EKS)
- **Управління пакетами**: Helm
- **Веб-фреймворк**: Django
- **База даних**: PostgreSQL
- **Веб-сервер**: Nginx, Gunicorn

## Критерії прийняття завдання ✅

### Урок 7 - Результат виконання:
1. ✅ **Кластер Kubernetes створений через Terraform і працює**
2. ✅ **ECR створений і містить Django Docker-образ**
3. ✅ **Deployment, Service і HPA створені через Helm**
4. ✅ **ConfigMap створено та використовується застосунком**
5. ✅ **Документація створена українською мовою**

### Поточний стан інфраструктури:
- **EKS кластер**: `lesson-7-eks-cluster` з 2 worker nodes
- **ECR репозиторій**: Містить Django образи (ARM64 та AMD64)
- **Django застосунок**: Доступний через LoadBalancer
- **Автомасштабування**: Налаштовано HPA 2-6 подів
- **Конфігурація**: 9 змінних оточення в ConfigMap

## Автор
Проєкт виконаний в рамках курсу DevOps CI/CD