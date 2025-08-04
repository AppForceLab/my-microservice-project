# Урок 7: Kubernetes EKS з Helm

## Опис проєкту

Цей проєкт демонструє розгортання Django-застосунку в Amazon EKS (Elastic Kubernetes Service) з використанням Terraform та Helm.

## Архітектура

- **EKS Cluster**: Kubernetes кластер версії 1.28 з 2 worker nodes
- **VPC**: Використовує існуючу VPC з lesson-5 з публічними та приватними підмережами
- **ECR**: Elastic Container Registry для зберігання Docker образів
- **Helm Chart**: Для управління розгортанням застосунку
- **Load Balancer**: Для зовнішнього доступу до застосунку
- **HPA**: Horizontal Pod Autoscaler для масштабування

## Компоненти

### Terraform модулі:
- `modules/eks/` - EKS кластер та node group
- `modules/ecr/` - Elastic Container Registry
- `modules/vpc/` - Virtual Private Cloud (з lesson-5)
- `modules/s3-backend/` - S3 backend для Terraform state

### Helm Chart:
- `charts/django-app/templates/deployment.yaml` - Django застосунок
- `charts/django-app/templates/service.yaml` - LoadBalancer сервіс
- `charts/django-app/templates/configmap.yaml` - Змінні оточення
- `charts/django-app/templates/hpa.yaml` - Horizontal Pod Autoscaler
- `charts/django-app/values.yaml` - Конфігурація

## Розгортання

### Попередні вимоги

1. AWS CLI налаштовано
2. Terraform встановлено
3. kubectl встановлено
4. Helm встановлено
5. Docker встановлено

### Кроки розгортання

1. **Ініціалізація Terraform:**
   ```bash
   cd lesson-7
   terraform init
   terraform plan
   terraform apply
   ```

2. **Налаштування kubectl:**
   ```bash
   aws eks update-kubeconfig --region eu-west-1 --name lesson-7-eks-cluster
   ```

3. **Перевірка вузлів:**
   ```bash
   kubectl get nodes
   ```

4. **Розгортання застосунку:**
   ```bash
   helm install django-app ./charts/django-app
   ```

5. **Перевірка розгортання:**
   ```bash
   kubectl get all
   ```

## Результати розгортання

### Створені ресурси AWS:
- ✅ EKS Cluster: `lesson-7-eks-cluster`
- ✅ ECR Repository: `lesson-7-ecr`
- ✅ VPC з публічними та приватними підмережами
- ✅ S3 bucket для Terraform state
- ✅ DynamoDB таблиця для блокувань

### Kubernetes ресурси:
- ✅ Deployment: 2 репліки застосунку
- ✅ Service: LoadBalancer для зовнішнього доступу
- ✅ ConfigMap: 9 змінних оточення
- ✅ HPA: Автомасштабування від 2 до 6 подів при CPU > 70%

### Доступ до застосунку:
```
URL: http://ac9cac65fa15d404a8d5f5e014141b3e-1810740142.eu-west-1.elb.amazonaws.com
Status: HTTP 200 OK
```

## Terraform Outputs

```bash
terraform output
```

Основні outputs:
- `eks_cluster_name`: Ім'я EKS кластера
- `eks_cluster_endpoint`: Endpoint кластера
- `ecr_url`: URL ECR репозиторію
- `vpc_id`: ID VPC

## Моніторинг та управління

### Перевірка стану подів:
```bash
kubectl get pods
```

### Перевірка HPA:
```bash
kubectl get hpa
```

### Перевірка логів:
```bash
kubectl logs -l app.kubernetes.io/name=django-app
```

### Масштабування:
```bash
kubectl scale deployment django-app --replicas=3
```

## Завантаження Django образу в ECR

1. **Автентифікація в ECR:**
   ```bash
   aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 381492144666.dkr.ecr.eu-west-1.amazonaws.com
   ```

2. **Збірка образу:**
   ```bash
   cd ../lesson-4
   docker build -t django-app .
   ```

3. **Тегування та завантаження:**
   ```bash
   docker tag django-app:latest 381492144666.dkr.ecr.eu-west-1.amazonaws.com/lesson-7-ecr:latest
   docker push 381492144666.dkr.ecr.eu-west-1.amazonaws.com/lesson-7-ecr:latest
   ```

4. **Оновлення Helm chart:**
   ```bash
   helm upgrade django-app ./charts/django-app --set image.repository=381492144666.dkr.ecr.eu-west-1.amazonaws.com/lesson-7-ecr
   ```

## Очищення ресурсів

```bash
helm uninstall django-app
terraform destroy
```

## Структура проєкту

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

## Змінні оточення в ConfigMap

- `SECRET_KEY`: Django secret key
- `DEBUG`: Режим налагодження
- `ALLOWED_HOSTS`: Дозволені хости
- `DB_ENGINE`: Рушій бази даних
- `DB_NAME`: Ім'я бази даних
- `DB_USER`: Користувач БД
- `DB_PASSWORD`: Пароль БД
- `DB_HOST`: Хост БД
- `DB_PORT`: Порт БД

## Вирішення проблем

### Проблеми з підключенням до кластера:
```bash
aws eks update-kubeconfig --region eu-west-1 --name lesson-7-eks-cluster
```

### Проблеми з Helm:
```bash
helm list
helm status django-app
```

### Проблеми з LoadBalancer:
```bash
kubectl describe service django-app
```

## Критерії прийняття завдання

✅ **1. Кластер Kubernetes створений через Terraform і працює**
- EKS кластер `lesson-7-eks-cluster` створено
- 2 worker nodes у статусі Ready
- Версія Kubernetes: 1.28.15-eks-473151a

✅ **2. ECR створений і готовий для завантаження Docker-образу**
- ECR репозиторій `lesson-7-ecr` створено
- URL: `381492144666.dkr.ecr.eu-west-1.amazonaws.com/lesson-7-ecr`
- Налаштовано сканування при завантаженні

✅ **3. Deployment, Service і HPA створені та працюють через Helm**
- Helm chart `django-app` розгорнуто (ревізія 2)
- Deployment: 2/2 реплік готові
- Service: LoadBalancer з зовнішнім IP
- HPA: налаштовано масштабування 2-6 подів при CPU > 70%

✅ **4. ConfigMap створено та використовується застосунком**  
- ConfigMap `django-app-config` з 9 змінними оточення
- Підключено до Deployment через `envFrom`
- Містить всі необхідні змінні з lesson-4

✅ **5. Проєкт готовий до push у GitHub з документацією**
- README.md створено українською мовою
- Документація містить всі необхідні кроки
- Структура проєкту описана