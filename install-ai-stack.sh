#!/bin/bash

echo "🚀 Быстрая установка AI Infrastructure - БЕЗ ОЖИДАНИЯ!"
echo "🎯 Прогоняем все сервисы, потом смотрим в kubectl!"

# Создаем namespace
echo "📦 Создаем namespace ai-infra..."
kubectl create namespace ai-infra --dry-run=client -o yaml | kubectl apply -f -

# 🤖 Устанавливаем отдельный Ollama (если есть standalone values)
if [ -f "./charts/ollama-standalone-values.yaml" ]; then
  echo "🤖 Устанавливаем Standalone Ollama..."
  helm upgrade --install ollama-standalone ./charts/ollama \
    --namespace ai-infra \
    --values ./charts/ollama-standalone-values.yaml
  echo "✅ Standalone Ollama запущен"
fi

# 🌐 Устанавливаем Open WebUI с встроенным Ollama (МОЩНАЯ КОНФИГУРАЦИЯ!)
echo "🌐 Устанавливаем Open WebUI с встроенным Ollama..."
helm upgrade --install open-webui ./charts/open-webui \
  --namespace ai-infra \
  --values ./charts/open-webui-values.yaml

echo "✅ Open WebUI запущен (с 96GB RAM + 40 cores!)"

# 📊 Устанавливаем JupyterHub
echo "📊 Устанавливаем JupyterHub..."
helm upgrade --install jupyterhub ./charts/jupyterhub \
  --namespace ai-infra \
  --values ./charts/jupyterhub-values.yaml

echo "✅ JupyterHub запущен"

# 📈 Устанавливаем MLflow
echo "📈 Устанавливаем MLflow..."
helm upgrade --install mlflow ./charts/mlflow \
  --namespace ai-infra \
  --values ./charts/mlflow-values.yaml

echo "✅ MLflow запущен"

echo ""
echo "🎉 ВСЕ СЕРВИСЫ ЗАПУЩЕНЫ В ФОНЕ!"
echo "🔥 Конфигурация: 96GB RAM + 40 CPU cores + GPU!"
echo ""
echo "🎯 Доступные сервисы:"
echo "   🤖 Embedded Ollama: http://open-webui-ollama:11434 (80GB RAM!)"
echo "   🌐 Open WebUI: http://ai.local"
echo "   📊 JupyterHub: http://jupyter.local"
echo "   📈 MLflow: http://mlflow.local"
echo ""
echo "🔑 Учетные данные:"
echo "   - JupyterHub: любой логин / ai-infra-password"
echo ""
echo "📋 КОМАНДЫ ДЛЯ ПРОВЕРКИ СТАТУСА:"
echo ""
echo "# Статус всех подов"
echo "kubectl get pods -n ai-infra"
echo ""
echo "# Детальный статус подов"
echo "kubectl get pods -n ai-infra -o wide"
echo ""
echo "# PVC и хранилище"
echo "kubectl get pvc -n ai-infra"
echo ""
echo "# Сервисы"
echo "kubectl get svc -n ai-infra"
echo ""
echo "# Ingress"
echo "kubectl get ingress -n ai-infra"
echo ""
echo "# События (если что-то не работает)"
echo "kubectl get events -n ai-infra --sort-by=.metadata.creationTimestamp"
echo ""
echo "# Следить за статусом в реальном времени"
echo "watch 'kubectl get pods -n ai-infra'"
echo ""
echo "🚀 ГОТОВО! Иди проверяй в kubectl!"
echo "🔥 Как только поды запустятся - будет МОНСТР AI инфраструктура!"
