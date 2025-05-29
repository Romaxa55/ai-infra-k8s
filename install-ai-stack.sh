#!/bin/bash

echo "🚀 Установка AI Infrastructure через локальные Helm Charts..."

# Создаем namespace
echo "📦 Создаем namespace ai-infra..."
kubectl create namespace ai-infra --dry-run=client -o yaml | kubectl apply -f -

# Устанавливаем MinIO (сначала для S3 storage)
echo "🗄️ Устанавливаем MinIO..."
helm upgrade --install minio ./charts/minio \
  --namespace ai-infra \
  --values ./charts/minio-values.yaml \
  --wait --timeout 10m

# Устанавливаем Ollama
echo "🤖 Устанавливаем Ollama..."
helm upgrade --install ollama ./charts/ollama \
  --namespace ai-infra \
  --values ./charts/ollama-values.yaml \
  --wait --timeout 10m

# Ждем пока Ollama запустится
echo "⏳ Ждем запуска Ollama..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=ollama -n ai-infra --timeout=300s

# Устанавливаем Open WebUI
echo "🌐 Устанавливаем Open WebUI..."
helm upgrade --install open-webui ./charts/open-webui \
  --namespace ai-infra \
  --values ./charts/open-webui-values.yaml \
  --wait --timeout 10m

# Устанавливаем JupyterHub
echo "📊 Устанавливаем JupyterHub..."
helm upgrade --install jupyterhub ./charts/jupyterhub \
  --namespace ai-infra \
  --values ./charts/jupyterhub-values.yaml \
  --wait --timeout 15m

# Устанавливаем MLflow
echo "📈 Устанавливаем MLflow..."
helm upgrade --install mlflow ./charts/mlflow \
  --namespace ai-infra \
  --values ./charts/mlflow-values.yaml \
  --wait --timeout 15m

echo "✅ Установка завершена!"
echo ""
echo "🎯 Доступные сервисы:"
echo "   - Ollama: http://ollama.ai-infra.svc.cluster.local:11434"
echo "   - Open WebUI: http://ai.local"
echo "   - JupyterHub: http://jupyter.local"
echo "   - MinIO Console: http://minio.local"
echo "   - MinIO API: http://minio-api.local"
echo "   - MLflow: http://mlflow.local"
echo ""
echo "🔑 Учетные данные:"
echo "   - JupyterHub: любой логин / ai-infra-password"
echo "   - MinIO: admin / ai-infra-minio-password"
echo ""
echo "📋 Проверка статуса:"
echo "   kubectl get pods -n ai-infra"
echo "   kubectl get svc -n ai-infra"
echo "   kubectl get ingress -n ai-infra"
echo "   kubectl get pvc -n ai-infra"
echo ""
echo "🤖 Загрузка моделей в Ollama:"
echo "   kubectl exec -it deployment/ollama -n ai-infra -- ollama pull llama3.2:3b"
echo "   kubectl exec -it deployment/ollama -n ai-infra -- ollama pull codellama:7b"
echo "   kubectl exec -it deployment/ollama -n ai-infra -- ollama pull qwen2.5:7b" 