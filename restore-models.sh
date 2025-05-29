#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "❌ Использование: $0 <backup-file.tar.gz>"
    echo "Пример: $0 ollama-models-backup-20250529_083000.tar.gz"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Файл backup не найден: $BACKUP_FILE"
    exit 1
fi

echo "🔄 Восстановление моделей из backup: $BACKUP_FILE"

# Получаем имя пода Ollama
OLLAMA_POD=$(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}')

if [ -z "$OLLAMA_POD" ]; then
    echo "❌ Не найден под Ollama!"
    exit 1
fi

echo "📦 Найден под: $OLLAMA_POD"

# Показываем текущие модели до восстановления
echo "📋 Текущие модели до восстановления:"
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama list

echo "📤 Копирование backup в под..."
kubectl cp $BACKUP_FILE ai-infra/$OLLAMA_POD:/tmp/

echo "🗜️ Извлечение моделей..."
kubectl exec -it $OLLAMA_POD -n ai-infra -- tar -xzf /tmp/$BACKUP_FILE -C /root/.ollama/

# Очищаем временный файл
kubectl exec -it $OLLAMA_POD -n ai-infra -- rm /tmp/$BACKUP_FILE

echo "📋 Модели после восстановления:"
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama list

echo "📊 Размер директории моделей:"
kubectl exec -it $OLLAMA_POD -n ai-infra -- du -sh /root/.ollama/models/

echo ""
echo "✅ Модели успешно восстановлены!"
echo ""
echo "🎯 Теперь можно использовать восстановленные модели в Open WebUI!" 