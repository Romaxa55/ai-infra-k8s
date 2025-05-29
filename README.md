# AI Infrastructure на Kubernetes

Бесплатная AI-инфраструктура на Kubernetes с поддержкой GPU для локального развертывания LLM и ML сервисов.

## 🏗️ Архитектура

### Компоненты:
- **Ollama** - Локальный запуск LLM моделей с GPU поддержкой
- **Open WebUI** - Веб-интерфейс для работы с LLM (аналог ChatGPT)
- **Jupyter** - Notebooks для ML/AI разработки с GPU
- **MLflow** - Tracking экспериментов ML (планируется)
- **MinIO** - S3-совместимое хранилище (планируется)

### Требования:
- Kubernetes кластер (K3s/K8s)
- Нода с NVIDIA GPU
- NVIDIA drivers установлены
- Longhorn для storage

## 🚀 Быстрый старт

### 1. Клонируйте репозиторий
```bash
git clone <repo-url>
cd ai-infra-k8s
```

### 2. Запустите развертывание
```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. Настройте доступ
Добавьте в `/etc/hosts`:
```
<IP_ВАШЕГО_КЛАСТЕРА> ai.local jupyter.local
```

### 4. Загрузите модели в Ollama
```bash
# Легкая модель для начала (3B параметров)
kubectl exec -it deployment/ollama -n ollama -- ollama pull llama3.2:3b

# Модель для кода
kubectl exec -it deployment/ollama -n ollama -- ollama pull codellama:7b

# Более мощная модель (если хватает VRAM)
kubectl exec -it deployment/ollama -n ollama -- ollama pull llama3.2:8b
```

## 🔗 Доступ к сервисам

- **Open WebUI**: http://ai.local
- **Jupyter**: http://jupyter.local (токен: `ai-jupyter-token`)

## 📊 Мониторинг

```bash
# Статус подов
kubectl get pods -n ollama
kubectl get pods -n jupyter

# Использование GPU
kubectl describe node k3s-worker1 | grep nvidia.com/gpu

# Логи Ollama
kubectl logs -f deployment/ollama -n ollama
```

## 🎮 GPU Конфигурация

Ваша нода с GPU:
- **GPU**: NVIDIA GeForce RTX 3050 (6GB VRAM)
- **CPU**: 40 cores
- **Memory**: ~147GB RAM
- **CUDA**: 12.2

### Оптимизация для RTX 3050:
- Используйте модели до 7B параметров
- Для больших моделей используйте квантизацию
- Настройте GPU sharing между сервисами

## 📝 Полезные команды

### Управление моделями Ollama:
```bash
# Список моделей
kubectl exec -it deployment/ollama -n ollama -- ollama list

# Удаление модели
kubectl exec -it deployment/ollama -n ollama -- ollama rm <model-name>

# Запуск модели
kubectl exec -it deployment/ollama -n ollama -- ollama run llama3.2:3b
```

### Отладка:
```bash
# Проверка GPU
kubectl describe node k3s-worker1 | grep -A 10 -B 10 nvidia

# Логи всех сервисов
kubectl logs -f deployment/ollama -n ollama
kubectl logs -f deployment/open-webui -n ollama
kubectl logs -f deployment/jupyter -n jupyter
```

## 🔧 Кастомизация

### Изменение ресурсов:
Отредактируйте файлы в соответствующих директориях:
- `ollama/ollama-deployment.yaml` - ресурсы Ollama
- `jupyter/jupyter-deployment.yaml` - ресурсы Jupyter
- `open-webui/open-webui-deployment.yaml` - ресурсы WebUI

### Добавление новых сервисов:
1. Создайте директорию для сервиса
2. Добавьте deployment.yaml
3. Обновите deploy.sh

## 🛠️ Troubleshooting

### GPU не доступен:
```bash
# Проверьте NVIDIA device plugin
kubectl get pods -n kube-system | grep nvidia

# Проверьте labels ноды
kubectl get nodes --show-labels | grep gpu
```

### Проблемы с storage:
```bash
# Проверьте Longhorn
kubectl get pods -n longhorn-system

# Проверьте PVC
kubectl get pvc -A
```

## 📈 Планы развития

- [ ] MLflow для tracking экспериментов
- [ ] MinIO для хранения данных и моделей
- [ ] Grafana для мониторинга GPU
- [ ] Автоматическое масштабирование
- [ ] Model serving с TensorFlow Serving
- [ ] Vector database (Qdrant/Weaviate)

## 🤝 Вклад в проект

1. Fork репозиторий
2. Создайте feature branch
3. Commit изменения
4. Push в branch
5. Создайте Pull Request

## 📄 Лицензия

MIT License
