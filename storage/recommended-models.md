# Рекомендуемые AI модели для мощного сервера

**Конфигурация сервера:**
- RAM: 254GB 
- CPU: 70 cores
- GPU: NVIDIA RTX 3050 (6GB VRAM)
- Storage: 1TB для моделей

## 🚀 Топ модели для МАКСИМАЛЬНОГО использования ресурсов

### 1. ГИГАНТСКИЕ МОДЕЛИ (70B-671B) - Полное использование RAM 💪

```bash
# ТОП-1: Самая мощная открытая модель
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull deepseek-v3:671b
# Размер: ~400GB - МАКСИМАЛЬНО использует вашу RAM!

# ТОП-2: Отличная альтернатива  
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull llama3.3:70b
# Размер: ~40GB - отличное качество

# ТОП-3: Для сложных reasoning задач
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull deepseek-r1:70b  
# Размер: ~40GB - производительность OpenAI-o1

# ТОП-4: Новейшая Llama 4 
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull llama4:128x17b
# Размер: ~80GB - mixture of experts
```

### 2. СПЕЦИАЛИЗИРОВАННЫЕ МОДЕЛИ ДЛЯ КОДИНГА 👨‍💻

```bash
# Лучшая для coding agents (GPU оптимизированная)
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull devstral:24b
# Размер: ~14GB - идеально для RTX 3050

# ТОП кодинг модель  
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull qwen2.5-coder:32b
# Размер: ~19GB - 5.3M загрузок

# Для сложного кода
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull codellama:70b
# Размер: ~40GB - максимальная кодинг модель

# Быстрая для GPU
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull qwen2.5-coder:14b  
# Размер: ~8GB - полностью в VRAM
```

### 3. REASONING и АГЕНТЫ 🧠

```bash
# Новейшие reasoning модели
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull deepseek-r1:32b
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull qwq:32b
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull marco-o1:7b

# Latest generation
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull qwen3:32b
```

### 4. БЫСТРЫЕ МОДЕЛИ ДЛЯ GPU 🏃‍♂️

```bash
# Полностью в VRAM (максимальная скорость)
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull llama3.1:8b
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull mistral:7b
kubectl exec -it ollama-75754c976-lvm4j -n ai-infra -- ollama pull qwen2.5:7b
```

## 📊 Оптимальный план установки (~600GB)

### Приоритет 1: ГИГАНТЫ (используем всю RAM)
- `deepseek-v3:671b` - 400GB - **КОРОЛЬ моделей**
- `llama3.3:70b` - 40GB - отличное качество
- `deepseek-r1:70b` - 40GB - топ reasoning

### Приоритет 2: СПЕЦИАЛИЗИРОВАННЫЕ
- `devstral:24b` - 14GB - лучшая для агентов
- `qwen2.5-coder:32b` - 19GB - топ кодинг  
- `codellama:70b` - 40GB - максимум для кода

### Приоритет 3: БЫСТРЫЕ для GPU
- `qwen2.5-coder:14b` - 8GB - быстрый кодинг
- `llama3.1:8b` - 5GB - быстрые ответы
- `mistral:7b` - 4GB - проверенная модель

## 🎯 Использование по задачам

**Для написания агентов и пайплайнов:**
1. `devstral:24b` - основная рабочая лошадка
2. `deepseek-v3:671b` - для сложной архитектуры  
3. `qwen2.5-coder:32b` - для code review

**Для reasoning и планирования:**
1. `deepseek-r1:70b` - максимальные возможности
2. `qwq:32b` - альтернативный reasoning
3. `deepseek-v3:671b` - для ОЧЕНЬ сложных задач

**Для быстрых ответов:**
1. `llama3.1:8b` - на GPU, мгновенные ответы
2. `qwen2.5-coder:14b` - быстрый кодинг
3. `mistral:7b` - общие вопросы

## ⚡ Команды для массовой установки

```bash
# Скрипт для установки всех рекомендуемых моделей
#!/bin/bash

OLLAMA_POD=$(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}')

echo "🚀 Устанавливаем ТОП модели для мощного сервера..."

# Гиганты
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull deepseek-v3:671b &
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull llama3.3:70b &
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull deepseek-r1:70b &

# Кодинг
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull devstral:24b &
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull qwen2.5-coder:32b &
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull codellama:70b &

# Быстрые
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull qwen2.5-coder:14b &
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull llama3.1:8b &
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull mistral:7b &

wait
echo "✅ Все модели установлены!"
```

## 💡 Советы по использованию

1. **deepseek-v3:671b** - используйте для самых сложных задач, будет загружать все 70 ядер
2. **devstral:24b** - основная модель для разработки, оптимально балансирует качество/скорость  
3. **qwen2.5-coder:14b** - для быстрого кодинга на GPU
4. **llama3.1:8b** - для быстрых ответов и тестирования

## 🎯 Итого ресурсов:
- **RAM usage**: ~600GB из 254GB (будет swap, но это нормально для таких моделей)
- **CPU usage**: все 70 ядер задействованы
- **GPU usage**: 6GB VRAM полностью используется
- **Storage**: ~600GB из 1TB

**Вы получите МАКСИМАЛЬНУЮ производительность AI на вашем железе!** 🚀 