# Storage Strategy для AI Infrastructure

## Распределение по типам storage

### SSD (2TB) - Быстрый доступ
**Компоненты:**
- Ollama активные модели (до 7B параметров)
- Jupyter рабочие данные
- Open WebUI данные
- Docker images
- Временные файлы обучения

**Размеры:**
- Ollama: 100GB (20-30 моделей)
- Jupyter: 500GB (notebooks + datasets)
- WebUI: 5GB
- Docker: 100GB
- Temp ML: 300GB
- Резерв: 1TB

### HDD (4TB) - Архивное хранение
**Компоненты:**
- Большие модели (70B+)
- Архивные datasets
- MLflow эксперименты
- MinIO объекты
- Бэкапы

**Размеры:**
- Большие модели: 1TB
- Datasets архив: 1.5TB
- MLflow: 500GB
- MinIO: 500GB
- Бэкапы: 500GB

## Storage Classes

### Для SSD (когда будет добавлен):
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-ssd
  labels:
    storage-type: "ssd"
    performance: "high"
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "2"
  diskSelector: "ssd"
  dataLocality: "best-effort"
```

### Для HDD (текущий):
```yaml
storageClassName: longhorn  # 2 реплики, HDD
```

## Миграционная стратегия

1. **Сейчас**: Все на HDD (longhorn, 2 реплики)
2. **После добавления SSD**: 
   - Активные модели → SSD
   - Архив → HDD
3. **Автоматическая миграция**: По расписанию или по использованию

## Мониторинг

- Отслеживать заполнение SSD
- Автоматически перемещать неиспользуемые модели на HDD
- Алерты при заполнении > 80% 