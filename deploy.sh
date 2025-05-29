#!/bin/bash

echo "🚀 Развертывание AI Infrastructure в Kubernetes..."

# Проверяем подключение к кластеру
echo "📋 Проверяем подключение к кластеру..."
kubectl cluster-info

# Создаем namespaces
echo "📁 Создаем namespaces..."
kubectl apply -f namespaces/namespaces.yaml

# Проверяем storage classes
echo "💾 Проверяем доступные storage classes..."
kubectl get storageclass

# Развертываем NVIDIA device plugin
echo "🎮 Развертываем NVIDIA device plugin..."
kubectl apply -f nvidia-device-plugin/nvidia-device-plugin.yaml

# Ждем готовности device plugin
echo "⏳ Ждем готовности NVIDIA device plugin..."
kubectl wait --for=condition=ready pod -l name=nvidia-device-plugin-ds -n kube-system --timeout=300s

# Проверяем доступность GPU
echo "🔍 Проверяем доступность GPU..."
kubectl describe node k3s-worker1 | grep nvidia.com/gpu

# Развертываем Ollama
echo "🤖 Развертываем Ollama..."
kubectl apply -f ollama/ollama-deployment.yaml

# Развертываем Open WebUI
echo "🌐 Развертываем Open WebUI..."
kubectl apply -f open-webui/open-webui-deployment.yaml

# Развертываем Jupyter
echo "📊 Развертываем Jupyter..."
kubectl apply -f jupyter/jupyter-deployment.yaml

# Ждем готовности подов
echo "⏳ Ждем готовности всех сервисов..."
kubectl wait --for=condition=ready pod -l app=ollama -n ollama --timeout=600s
kubectl wait --for=condition=ready pod -l app=open-webui -n ollama --timeout=300s
kubectl wait --for=condition=ready pod -l app=jupyter -n jupyter --timeout=600s

# Показываем статус
echo "📊 Статус развертывания:"
kubectl get pods -n ollama
kubectl get pods -n jupyter
kubectl get svc -n ollama
kubectl get svc -n jupyter

echo "✅ Развертывание завершено!"
echo ""
echo "🔗 Доступ к сервисам:"
echo "   Open WebUI: http://ai.local (добавьте в /etc/hosts)"
echo "   Jupyter: http://jupyter.local (токен: ai-jupyter-token)"
echo ""
echo "📝 Для доступа добавьте в /etc/hosts:"
echo "   <IP_ВАШЕГО_КЛАСТЕРА> ai.local jupyter.local"
echo ""
echo "🤖 Для загрузки моделей в Ollama:"
echo "   kubectl exec -it deployment/ollama -n ollama -- ollama pull llama3.2:3b"
echo "   kubectl exec -it deployment/ollama -n ollama -- ollama pull codellama:7b"
echo ""
echo "💾 Используется storage: longhorn (HDD, 2 реплики)"
echo "📊 Доступно места на HDD: ~4TB" 