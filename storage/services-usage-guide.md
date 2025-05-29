# Полное руководство по сервисам AI инфраструктуры

## 🎯 Обзор установленных сервисов

### 1. **Open WebUI** 🌐 - Главный интерфейс для AI
- **URL**: http://ai.local
- **Назначение**: Основной интерфейс для общения с AI моделями
- **Улучшения**: Включен Redis для кэширования и сессий

### 2. **JupyterHub** 📊 - ML/AI разработка
- **Назначение**: Jupyter notebooks для ML экспериментов
- **Использование**: Анализ данных, тренировка моделей, исследования

### 3. **MinIO** 💾 - Объектное хранилище
- **Console URL**: http://minio.local  
- **API URL**: http://minio-api.local
- **Назначение**: S3-совместимое хранилище для файлов, моделей, данных

### 4. **Ollama** 🤖 - AI движок
- **Назначение**: Запуск и управление AI моделями
- **API**: http://ollama.ai-infra.svc.cluster.local:11434

### 5. **Redis** ⚡ - Кэширование (NEW!)
- **Назначение**: Кэширование ответов, сессии, websocket коммуникация
- **Улучшения**: Быстрые ответы, память о контексте

## 🚀 Как использовать каждый сервис

### Open WebUI - Главный интерфейс

```bash
# Доступ через браузер
http://ai.local

# Возможности с Redis:
✅ Кэширование ответов - быстрые повторные запросы
✅ Память о контексте между сессиями  
✅ Real-time websocket коммуникация
✅ Синхронизация между вкладками
```

**Что делать в Open WebUI:**
- Общаться с AI моделями
- Загружать документы для анализа
- Создавать промпты и шаблоны
- Управлять моделями
- Настраивать параметры генерации

### JupyterHub - ML/AI разработка

```bash
# Проверим статус JupyterHub
kubectl get pods -n ai-infra | grep jupyter

# Если нужно - подключимся к JupyterHub
kubectl port-forward -n ai-infra svc/jupyterhub 8000:80
# Затем: http://localhost:8000
```

**Что делать в JupyterHub:**
- Анализировать данные с AI моделями
- Создавать свои ML пайплайны
- Экспериментировать с новыми подходами
- Интеграция с Ollama API
- Визуализация результатов

**Пример notebook для работы с Ollama:**
```python
import requests
import json

# Подключение к Ollama
ollama_url = "http://ollama.ai-infra.svc.cluster.local:11434"

def chat_with_model(model, prompt):
    response = requests.post(f"{ollama_url}/api/generate", 
                           json={"model": model, "prompt": prompt})
    return response.json()

# Использование
result = chat_with_model("llama3.1:8b", "Объясни машинное обучение")
print(result['response'])
```

### MinIO - Объектное хранилище

```bash
# Проверим статус MinIO
kubectl get svc -n ai-infra | grep minio

# Подключимся к консоли
kubectl port-forward -n ai-infra svc/minio-console 9001:9001
# Затем: http://localhost:9001
```

**Что хранить в MinIO:**
- **Входные данные**: PDF, тексты, изображения для AI
- **Результаты**: Сгенерированные ответы, отчеты
- **Модели**: Собственные fine-tuned модели
- **Datasets**: Большие наборы данных для ML
- **Бэкапы**: Резервные копии важных данных

**Интеграция с Open WebUI:**
- Загружать документы из MinIO
- Сохранять результаты в MinIO
- Использовать как источник знаний

### Redis - Кэширование и производительность

```bash
# Проверим статус Redis
kubectl get pods -n ai-infra | grep redis

# Подключимся к Redis для мониторинга
kubectl exec -it open-webui-redis-xxx -n ai-infra -- redis-cli info
```

**Что улучшает Redis:**
- **Кэширование ответов**: Быстрые повторные запросы
- **Сессии**: Память о контексте между перезапусками
- **Websockets**: Real-time коммуникация
- **Производительность**: Снижение нагрузки на Ollama

## 🔧 Оптимизация использования

### Рабочий flow для разработки AI агентов:

1. **JupyterHub**: Исследование и прототипирование
2. **MinIO**: Хранение данных и результатов  
3. **Open WebUI**: Тестирование промптов
4. **Redis**: Кэширование для скорости

### Интеграция сервисов:

```python
# Пример полной интеграции в Jupyter
import boto3  # для MinIO
import requests  # для Ollama
import redis  # для кэширования

# MinIO клиент
minio_client = boto3.client(
    's3',
    endpoint_url='http://minio.ai-infra.svc.cluster.local:9000',
    aws_access_key_id='your-key',
    aws_secret_access_key='your-secret'
)

# Redis для кэширования
redis_client = redis.Redis(host='open-webui-redis', port=6379, db=0)

# Ollama для AI
def get_ai_response(prompt, use_cache=True):
    if use_cache:
        cached = redis_client.get(f"prompt:{hash(prompt)}")
        if cached:
            return json.loads(cached)
    
    response = requests.post("http://ollama:11434/api/generate", 
                           json={"model": "devstral:24b", "prompt": prompt})
    result = response.json()
    
    if use_cache:
        redis_client.setex(f"prompt:{hash(prompt)}", 3600, json.dumps(result))
    
    return result
```

## 📊 Мониторинг и управление

### Полезные команды:

```bash
# Статус всех сервисов
kubectl get pods -n ai-infra

# Ресурсы
kubectl top pods -n ai-infra

# Логи Open WebUI
kubectl logs -f open-webui-0 -n ai-infra

# Логи Ollama
kubectl logs -f ollama-xxx -n ai-infra

# Статус Redis
kubectl exec -it open-webui-redis-xxx -n ai-infra -- redis-cli info memory

# Использование MinIO
kubectl exec -it minio-xxx -n ai-infra -- mc admin info local
```

### Веб интерфейсы:

- **Open WebUI**: http://ai.local - основной интерфейс
- **MinIO Console**: подключение через port-forward
- **JupyterHub**: подключение через port-forward

## 🎯 Рекомендации по использованию

### Для написания агентов:
1. **Прототипирование**: JupyterHub
2. **Тестирование**: Open WebUI с Redis кэшированием
3. **Хранение**: MinIO для данных и результатов

### Для кодинга:
1. **Быстрые задачи**: Open WebUI + qwen2.5-coder:14b (GPU)
2. **Сложные проекты**: JupyterHub + devstral:24b
3. **Сохранение**: MinIO для кода и документации

### Для reasoning задач:
1. **Исследование**: Open WebUI + deepseek-r1:70b
2. **Анализ**: JupyterHub для детального изучения
3. **Кэширование**: Redis для быстрых повторных запросов

## 🚀 Обновление Open WebUI с Redis

Чтобы применить улучшения:

```bash
# Обновляем Open WebUI с Redis
helm upgrade open-webui ./charts/open-webui \
  --namespace ai-infra \
  --values ./charts/open-webui-values.yaml \
  --wait --timeout 10m
```

После обновления получите:
✅ Быстрое кэширование ответов
✅ Память о контексте
✅ Улучшенную производительность 
✅ Real-time коммуникацию 