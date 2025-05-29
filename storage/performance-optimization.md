# Оптимизация производительности AI инфраструктуры

**Конфигурация сервера:**
- RAM: 254GB
- CPU: 70 cores  
- GPU: NVIDIA RTX 3050 (6GB VRAM)
- Storage: 1TB NVMe

## 🚀 Настройки для максимальной производительности

### 1. Ollama конфигурация для мощного железа

```yaml
# charts/ollama-values.yaml - обновленная конфигурация
resources:
  requests:
    memory: "8Gi"
    cpu: "2000m"
    nvidia.com/gpu: 1
  limits:
    memory: "200Gi"  # Увеличено для больших моделей
    cpu: "50000m"    # 50 cores из 70 доступных
    nvidia.com/gpu: 1

# Переменные окружения для максимальной производительности
env:
  OLLAMA_NUM_PARALLEL: "8"        # Параллельные запросы
  OLLAMA_MAX_LOADED_MODELS: "5"   # Держим 5 моделей в памяти
  OLLAMA_GPU_OVERHEAD: "1Gi"      # GPU overhead
  OLLAMA_MAX_QUEUE: "512"         # Большая очередь
```

### 2. Open WebUI настройки для производительности

```yaml
# charts/open-webui-values.yaml - обновленная конфигурация  
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "8Gi"     # Увеличено для кэширования
    cpu: "4000m"      # 4 cores

# Переменные для производительности
env:
  WEBUI_AUTH: "false"
  OLLAMA_BASE_URL: "http://ollama.ai-infra.svc.cluster.local:11434"
  # Кэширование ответов
  ENABLE_RESPONSE_CACHE: "true"
  RESPONSE_CACHE_SIZE: "1000"
  # Оптимизация интерфейса
  WEBUI_MAX_FILE_SIZE: "100MB"
```

### 3. Kubernetes ресурсы для AI нагрузок

```yaml
# Лимиты namespace для AI инфраструктуры
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ai-infra-quota
  namespace: ai-infra
spec:
  hard:
    requests.cpu: "60"      # 60 из 70 cores
    requests.memory: "240Gi" # 240 из 254GB RAM
    limits.cpu: "70"        # Все cores
    limits.memory: "254Gi"  # Вся RAM
    nvidia.com/gpu: "1"     # GPU
```

## ⚡ Оптимизация моделей по задачам

### Быстрые ответы (GPU оптимизированные)
```bash
# Модели полностью в VRAM - мгновенные ответы
llama3.1:8b      # 5GB  - общие задачи
mistral:7b       # 4GB  - быстрые ответы  
qwen2.5-coder:14b # 8GB  - кодинг на GPU
```

### Средние задачи (GPU + RAM)
```bash
# Баланс скорости и качества
devstral:24b         # 14GB - агенты и пайплайны
qwen2.5-coder:32b    # 19GB - сложный кодинг
deepseek-r1:32b      # 19GB - reasoning задачи
```

### Сложные задачи (максимальное качество)
```bash
# Используют всю мощь сервера
llama3.3:70b         # 40GB - топ качество
deepseek-r1:70b      # 40GB - топ reasoning  
deepseek-v3:671b     # 400GB - максимум возможностей
```

## 🎯 Стратегии использования ресурсов

### Параллельная обработка
```bash
# Ollama может обрабатывать несколько запросов одновременно
# С 70 cores можем запускать:
# - 2-3 больших модели (70B) параллельно
# - 5-8 средних моделей (32B) параллельно  
# - 10+ маленьких моделей (8B) параллельно
```

### Оптимальное распределение нагрузки
```
GPU (6GB VRAM):
├── qwen2.5-coder:14b (для кодинга)
└── Резерв для inference

RAM (254GB):
├── deepseek-v3:671b (400GB с swap)
├── llama3.3:70b (40GB)
├── deepseek-r1:70b (40GB)
├── devstral:24b (14GB)
└── Буферы и кэш

CPU (70 cores):
├── 50 cores для Ollama
├── 8 cores для Open WebUI
├── 4 cores для системы
└── 8 cores резерв
```

## 🔧 Команды для мониторинга производительности

```bash
# Мониторинг GPU
kubectl exec -it ollama-pod -n ai-infra -- nvidia-smi -l 1

# Мониторинг ресурсов
kubectl top nodes
kubectl top pods -n ai-infra

# Проверка загрузки моделей
kubectl exec -it ollama-pod -n ai-infra -- ollama ps

# Логи производительности
kubectl logs -f ollama-pod -n ai-infra
```

## 📊 Бенчмарки ожидаемой производительности

### Быстрые модели (GPU)
- **llama3.1:8b**: ~200 tokens/sec
- **mistral:7b**: ~250 tokens/sec
- **qwen2.5-coder:14b**: ~150 tokens/sec

### Средние модели (GPU+RAM)
- **devstral:24b**: ~80 tokens/sec
- **qwen2.5-coder:32b**: ~60 tokens/sec
- **deepseek-r1:32b**: ~50 tokens/sec

### Большие модели (RAM)
- **llama3.3:70b**: ~25 tokens/sec
- **deepseek-r1:70b**: ~20 tokens/sec
- **deepseek-v3:671b**: ~5 tokens/sec (но максимальное качество!)

## 💡 Советы по оптимизации

1. **Предзагрузка моделей**: Держите часто используемые модели в памяти
2. **Кэширование**: Включите кэширование ответов в Open WebUI
3. **Batch обработка**: Группируйте похожие запросы
4. **Мониторинг**: Следите за использованием ресурсов
5. **Swap**: Настройте swap для работы с очень большими моделями

## 🎯 Итоговая стратегия

**Ваш сервер способен на:**
- Одновременную работу с 5-8 AI моделями
- Обработку сложных reasoning задач
- Быстрое выполнение кодинг задач на GPU
- Работу с самыми большими открытыми моделями

**Максимальная производительность достигается при:**
- Использовании GPU для моделей до 14B
- Предзагрузке часто используемых моделей  
- Параллельной обработке запросов
- Правильном распределении ресурсов между задачами 