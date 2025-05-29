#!/bin/bash

echo "🔄 Создание backup моделей Ollama..."

# Получаем имя пода Ollama
OLLAMA_POD=$(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}')

if [ -z "$OLLAMA_POD" ]; then
    echo "❌ Не найден под Ollama!"
    exit 1
fi

echo "📦 Найден под: $OLLAMA_POD"

# Проверяем размер моделей
echo "📊 Размер текущих моделей:"
kubectl exec -it $OLLAMA_POD -n ai-infra -- du -sh /root/.ollama/models/

# Список моделей
echo "📋 Список моделей:"
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama list

# Создаем timestamp для backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="ollama-models-backup-$TIMESTAMP.tar.gz"

echo "🗜️ Создание архива моделей..."
kubectl exec -it $OLLAMA_POD -n ai-infra -- tar -czf /tmp/$BACKUP_NAME -C /root/.ollama models/

echo "📥 Копирование backup на локальную машину..."
kubectl cp ai-infra/$OLLAMA_POD:/tmp/$BACKUP_NAME ./$BACKUP_NAME

# Очищаем временный файл
kubectl exec -it $OLLAMA_POD -n ai-infra -- rm /tmp/$BACKUP_NAME

# Проверяем размер backup'а
BACKUP_SIZE=$(du -sh $BACKUP_NAME | cut -f1)
echo "✅ Backup создан: $BACKUP_NAME (размер: $BACKUP_SIZE)"

echo ""
echo "🎯 Backup завершен!"
echo "Файл: $BACKUP_NAME"
echo ""
echo "Для восстановления используйте:"
echo "./restore-models.sh $BACKUP_NAME" 