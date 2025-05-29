# AI Infrastructure K8s Project Context

## Цель проекта
Развертывание бесплатной AI-инфраструктуры в Kubernetes кластере с использованием GPU ноды.

## Кластер информация
- **Control Plane**: debian-media-server (10.0.0.254)
- **Worker Node**: k3s-worker1 (10.0.0.250) - **GPU NODE**

### GPU Worker Node (k3s-worker1) характеристики:
- **CPU**: 40 cores (Intel, family 6, model 63)
- **Memory**: ~147GB RAM
- **GPU**: NVIDIA GeForce RTX 3050 (6GB VRAM, Ampere architecture)
- **CUDA**: Driver 535.216.01, Runtime 12.2
- **Storage**: 4TB HDD (текущий), 2TB SSD (планируется)
- **Labels**: `gpu=true`, `node=pve`
- **OS**: Debian GNU/Linux 12 (bookworm)

## Storage конфигурация
- **Текущий**: Longhorn с HDD 4TB
- **Storage Class**: `longhorn` (2 реплики, настроено в Longhorn UI)
- **Планируется**: Добавить 2TB SSD для быстрого storage

### Storage классы:
- `longhorn` - 2 реплики (default, используется для AI)
- `longhorn-no-replicas` - 1 реплика
- `longhorn-static` - статический
- `local-path` - локальные пути

## Компоненты для развертывания
1. **Ollama** - Локальный запуск LLM моделей (50GB storage)
2. **Open WebUI** - Веб-интерфейс для работы с LLM (5GB storage)
3. **Jupyter** - Notebooks для ML/AI разработки (20GB storage)
4. **MLflow** - Tracking экспериментов ML (планируется)
5. **MinIO** - S3-совместимое хранилище (планируется)
6. **NVIDIA Device Plugin** - Для работы с GPU
7. **Storage** - Используем longhorn-no-replicas
8. **Namespaces** - Изоляция компонентов

## Текущий статус
- Кластер работает
- GPU нода готова (NVIDIA drivers установлены)
- Longhorn настроен с HDD storage
- Готово к развертыванию AI компонентов

## Следующие шаги
1. Настроить namespaces ✓
2. Развернуть NVIDIA device plugin
3. Развернуть Ollama с GPU поддержкой
4. Развернуть Open WebUI
5. Настроить Jupyter с GPU доступом
6. Развернуть MLflow и MinIO
7. Добавить SSD storage (когда будет готов)

## Особенности
- Используем бесплатные open-source решения
- Максимально используем GPU ресурсы RTX 3050
- Storage без репликации (single node setup)
- Оптимизировано для HDD (пока) 