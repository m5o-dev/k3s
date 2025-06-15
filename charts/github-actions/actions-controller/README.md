# 🎮 GitHub Actions Controller

**Controlador central para gerenciar GitHub Actions Runners no cluster k3s.**

Este chart instala o **Actions Runner Controller (ARC)** que gerencia os runners de forma automática.

## 📦 Instalação

```bash
# 1. Baixar dependências
helm dependency build

# 2. Instalar controller
helm install actions-controller . \
  --namespace arc-system \
  --create-namespace
```

## 🔍 Verificação

```bash
# Verificar se está rodando
kubectl get pods -n arc-system

# Ver logs
kubectl logs -n arc-system deployment/actions-controller-gha-runner-scale-set-controller
```

## ⚙️ Configuração

O controller usa configurações padrão otimizadas para k3s. Para customizar:

```bash
helm install actions-controller . \
  --namespace arc-system \
  --create-namespace \
  --set gha-runner-scale-set-controller.resources.limits.cpu="1000m" \
  --set gha-runner-scale-set-controller.resources.limits.memory="512Mi"
```

## 🗑️ Desinstalar

```bash
helm uninstall actions-controller -n arc-system
kubectl delete namespace arc-system
```

---

**⚠️ Importante:** Este controller deve ser instalado **antes** dos runners! 