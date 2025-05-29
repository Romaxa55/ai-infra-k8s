# Полное руководство по хранению AI моделей

## 🏠 Где хранятся модели в нашей инфраструктуре

### 1. **Ollama модели** 🤖 - Основное хранилище

**Текущий статус:** ⚠️ ТРЕБУЕТ ИСПРАВЛЕНИЯ
- **Где**: `/root/.ollama/models/` внутри контейнера Ollama
- **Проблема**: Модели хранятся в EmptyDir (временное хранилище)
- **Риск**: Модели пропадают при перезапуске пода!

```bash
# Проверить размер моделей
kubectl exec -it $(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}') -n ai-infra -- du -sh /root/.ollama/models/

# Список установленных моделей
kubectl exec -it $(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}') -n ai-infra -- ollama list
```

**Текущие модели:**
- `llama3.2:1b` - 1.3GB
- `llama3.2:3b` - 2.0GB
- **Потеряны**: devstral:24b, qwen2.5-coder и другие большие модели

### 2. **MinIO объектное хранилище** 💾 - Резервное хранилище

**Статус:** ✅ Работает с persistent storage
- **Где**: MinIO bucket с 200GB SSD storage
- **Назначение**: Резервные копии моделей, datasets, результаты
- **Доступ**: S3-совместимый API

```bash
# Подключение к MinIO консоли
kubectl port-forward -n ai-infra svc/minio-console 9001:9001
# Открыть: http://localhost:9001
```

### 3. **Open WebUI** 🌐 - Пользовательские данные

**Статус:** ✅ Persistent storage 20GB SSD
- **Где**: `/app/backend/data/` в контейнере
- **Что хранится**: Чаты, настройки, загруженные файлы
- **PVC**: `open-webui` - 20GB на longhorn-ssd

## 🔧 СРОЧНОЕ исправление хранения Ollama

### Проблема:
Ollama использует Deployment с EmptyDir вместо StatefulSet с PVC!

### Решение:

1. **Создать PVC для Ollama:**

```yaml
# ollama-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-data
  namespace: ai-infra
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn-ssd
  resources:
    requests:
      storage: 1000Gi  # 1TB для больших моделей
```

2. **Применить PVC:**
```bash
kubectl apply -f ollama-pvc.yaml
```

3. **Обновить Ollama на StatefulSet** (требует изменения в chart)

### Временное решение:
Пока исправляем, будем делать резервные копии моделей в MinIO.

## 📂 Стратегия хранения по типам моделей

### Активные модели (Ollama)
- **Быстрые модели (GPU)**: qwen2.5-coder:14b, llama3.1:8b
- **Рабочие модели**: devstral:24b, deepseek-r1:32b
- **Расположение**: SSD storage для быстрого доступа

### Архивные модели (MinIO)
- **Большие модели**: deepseek-v3:671b, llama3.3:70b
- **Экспериментальные**: модели для тестирования
- **Резервные копии**: backup активных моделей

### Пользовательские данные (Open WebUI)
- **Чаты и настройки**: быстрый SSD доступ
- **Загруженные файлы**: документы для RAG

## 🔄 Backup стратегия для моделей

### Автоматический backup в MinIO:

```bash
#!/bin/bash
# backup-models.sh

OLLAMA_POD=$(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}')

# Создаем архив моделей
kubectl exec -it $OLLAMA_POD -n ai-infra -- tar -czf /tmp/ollama-models-backup.tar.gz -C /root/.ollama models/

# Копируем на локальную машину
kubectl cp ai-infra/$OLLAMA_POD:/tmp/ollama-models-backup.tar.gz ./ollama-models-backup.tar.gz

# Загружаем в MinIO (требует настройки MC client)
# mc cp ollama-models-backup.tar.gz minio/ai-models/backups/

echo "Backup создан: ollama-models-backup.tar.gz"
```

### Восстановление из backup:

```bash
#!/bin/bash
# restore-models.sh

OLLAMA_POD=$(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}')

# Копируем backup в под
kubectl cp ./ollama-models-backup.tar.gz ai-infra/$OLLAMA_POD:/tmp/

# Восстанавливаем модели
kubectl exec -it $OLLAMA_POD -n ai-infra -- tar -xzf /tmp/ollama-models-backup.tar.gz -C /root/.ollama/

echo "Модели восстановлены!"
```

## 📊 Мониторинг использования хранилища

```bash
# Проверка всех PVC
kubectl get pvc -n ai-infra

# Использование дискового пространства в Ollama
kubectl exec -it $(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}') -n ai-infra -- df -h

# Размер моделей
kubectl exec -it $(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}') -n ai-infra -- du -sh /root/.ollama/models/*

# MinIO статистика
kubectl port-forward -n ai-infra svc/minio-console 9001:9001
# Открыть: http://localhost:9001
```

## 🎯 Рекомендации

### Немедленно:
1. ✅ Создать backup текущих моделей
2. ❌ Исправить Ollama storage на persistent
3. ✅ Настроить автоматический backup

### Архитектура хранения:
```
SSD Storage (longhorn-ssd):
├── Ollama активные модели (1TB)
├── Open WebUI данные (20GB)
├── MinIO объекты (200GB)
└── Резерв

HDD Storage (longhorn):
├── Архивные модели
├── Большие datasets
└── Долгосрочные backups
```

### Workflow для моделей:
1. **Установка**: Скачать в Ollama (SSD)
2. **Backup**: Автоматически в MinIO
3. **Архивирование**: Неиспользуемые модели в MinIO
4. **Восстановление**: Из MinIO обратно в Ollama

## ⚠️ СРОЧНО: Защита от потери моделей

**Немедленно выполните backup существующих моделей:**

```bash
# Создать backup скрипт
chmod +x backup-models.sh
./backup-models.sh
```

**До исправления Ollama PVC избегайте:**
- Перезапуска Ollama пода
- Обновления Ollama chart
- Перезагрузки worker node

**После создания backup'а можно:**
- Безопасно перезапускать поды
- Экспериментировать с конфигурациями
- Быстро восстанавливать модели 