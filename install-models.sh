#!/bin/bash

# Скрипт установки рекомендуемых AI моделей
# Для сервера: 254GB RAM + 70 cores + RTX 3050

set -e

echo "🚀 Установка ТОП AI моделей для мощного сервера"
echo "📊 Конфигурация: 254GB RAM + 70 cores + RTX 3050 (6GB)"

# Получаем имя пода Ollama
OLLAMA_POD=$(kubectl get pods -n ai-infra -l app.kubernetes.io/name=ollama -o jsonpath='{.items[0].metadata.name}')
if [ -z "$OLLAMA_POD" ]; then
    echo "❌ Ollama pod не найден!"
    exit 1
fi

echo "📦 Найден Ollama pod: $OLLAMA_POD"

# Функция установки модели
install_model() {
    local model=$1
    local description=$2
    echo "⬇️  Устанавливаем $model - $description"
    kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull $model
    echo "✅ $model установлена"
}

# Проверяем доступное место
echo "💾 Проверяем доступное место на диске..."
kubectl exec -it $OLLAMA_POD -n ai-infra -- df -h /root/.ollama/

read -p "🤔 Продолжить установку? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Установка отменена"
    exit 1
fi

echo "🎯 Начинаем установку моделей..."

# ПРИОРИТЕТ 1: Быстрые модели для GPU (устанавливаем первыми)
echo "🏃‍♂️ Устанавливаем быстрые модели для GPU..."
install_model "llama3.1:8b" "Быстрая модель для GPU (5GB)"
install_model "mistral:7b" "Проверенная модель (4GB)"
install_model "qwen2.5-coder:14b" "Быстрый кодинг для GPU (8GB)"

# ПРИОРИТЕТ 2: Специализированные модели среднего размера
echo "👨‍💻 Устанавливаем специализированные модели..."
install_model "devstral:24b" "Лучшая для coding agents (14GB)"
install_model "qwen2.5-coder:32b" "ТОП кодинг модель (19GB)"
install_model "deepseek-r1:32b" "Reasoning модель (19GB)"

# ПРИОРИТЕТ 3: Большие модели (устанавливаем в фоне)
echo "🐘 Устанавливаем большие модели (в фоне)..."

echo "⬇️  Запускаем фоновую установку больших моделей..."
{
    echo "📦 Устанавливаем llama3.3:70b (40GB)..."
    kubectl exec -i $OLLAMA_POD -n ai-infra -- ollama pull llama3.3:70b
    echo "✅ llama3.3:70b установлена"
} &

{
    echo "📦 Устанавливаем deepseek-r1:70b (40GB)..."  
    kubectl exec -i $OLLAMA_POD -n ai-infra -- ollama pull deepseek-r1:70b
    echo "✅ deepseek-r1:70b установлена"
} &

{
    echo "📦 Устанавливаем codellama:70b (40GB)..."
    kubectl exec -i $OLLAMA_POD -n ai-infra -- ollama pull codellama:70b  
    echo "✅ codellama:70b установлена"
} &

echo "⏰ Большие модели устанавливаются в фоне..."
echo "📋 Можете проверить прогресс: kubectl logs -f $OLLAMA_POD -n ai-infra"

# ДОПОЛНИТЕЛЬНО: Устанавливаем ГИГАНТСКУЮ модель отдельно
read -p "💪 Хотите установить ГИГАНТСКУЮ модель deepseek-v3:671b (~400GB)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🦣 Устанавливаем ГИГАНТСКУЮ модель deepseek-v3:671b..."
    echo "⚠️  Это займет много времени и места (~400GB)"
    kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama pull deepseek-v3:671b
    echo "✅ deepseek-v3:671b установлена!"
fi

echo "⏳ Ждем завершения фоновых установок..."
wait

echo ""
echo "🎉 Установка завершена!"
echo "📋 Проверим список установленных моделей:"
kubectl exec -it $OLLAMA_POD -n ai-infra -- ollama list

echo ""
echo "🎯 Рекомендации по использованию:"
echo "  • llama3.1:8b - для быстрых ответов (полностью в GPU)"
echo "  • devstral:24b - для разработки агентов и пайплайнов"
echo "  • qwen2.5-coder:32b - для сложного кодинга"
echo "  • llama3.3:70b - для сложных задач (использует всю RAM)"
echo "  • deepseek-r1:70b - для сложного reasoning"

echo ""
echo "🌐 Откройте Open WebUI: http://ai.local"
echo "✨ Наслаждайтесь мощью AI на вашем сервере!" 