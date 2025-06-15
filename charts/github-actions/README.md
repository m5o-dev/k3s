# 🚀 GitHub Actions para K3s

**Solução completa para executar GitHub Actions no seu cluster k3s.**

Esta solução é composta por **dois charts separados** que devem ser instalados na ordem correta:

## 📦 Componentes

### 1. 🎮 **actions-controller**
- Controlador central que gerencia os runners
- Deve ser instalado **primeiro**
- Roda no namespace `arc-system`

### 2. 🏃 **actions-runners** 
- Runners que executam os workflows
- Deve ser instalado **depois** do controller
- Roda no namespace de sua escolha

## 🔧 Instalação Completa

### **Passo 1: Instalar Controller**

```bash
cd charts/github-actions/actions-controller

# Baixar dependências
helm dependency build

# Instalar controller
helm install actions-controller . \
  --namespace arc-system \
  --create-namespace

# Verificar se está rodando
kubectl get pods -n arc-system
```

### **Passo 2: Instalar Runners**

```bash
cd ../actions-runners

# Baixar dependências  
helm dependency build

# Instalar runners
helm install meus-runners . \
  --namespace github-actions \
  --create-namespace \
  --set githubUrl="https://github.com/minha-org" \
  --set githubToken="ghp_xxxxxxxxxxxx" \
  --set runnerName="meus-runners"

# Verificar se está rodando
kubectl get pods -n github-actions
```

## 🔑 Token do GitHub

Crie um **Personal Access Token** no GitHub:

1. Acesse: https://github.com/settings/tokens/new
2. Selecione as permissões:
   - **Para repositórios:** `repo`
   - **Para organizações:** `admin:org`
3. Copie o token gerado

## 📋 Usar nos Workflows

Após a instalação, use nos seus workflows:

```yaml
name: Deploy no K3s
on: push

jobs:
  deploy:
    runs-on: meus-runners  # <- nome que você escolheu
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: |
          echo "🚀 Executando no meu cluster k3s!"
          kubectl get nodes
          kubectl apply -f k8s/
```

## 🔍 Verificação

```bash
# Controller
kubectl get pods -n arc-system
kubectl logs -n arc-system deployment/actions-controller-gha-runner-scale-set-controller

# Runners
kubectl get pods -n github-actions
kubectl logs -n github-actions deployment/meus-runners-scale-set-listener

# No GitHub
# Acesse: GitHub → Settings → Actions → Runners
```

## 🗑️ Desinstalar

```bash
# Remover runners primeiro
helm uninstall meus-runners -n github-actions
kubectl delete namespace github-actions

# Depois remover controller
helm uninstall actions-controller -n arc-system
kubectl delete namespace arc-system
```

## 🎯 Múltiplos Runners

Você pode instalar múltiplos runners para diferentes projetos:

```bash
# Runners para projeto A
helm install projeto-a-runners actions-runners/ \
  --namespace projeto-a \
  --create-namespace \
  --set githubUrl="https://github.com/empresa/projeto-a" \
  --set githubToken="ghp_xxxxxxxxxxxx" \
  --set runnerName="projeto-a-runners"

# Runners para projeto B  
helm install projeto-b-runners actions-runners/ \
  --namespace projeto-b \
  --create-namespace \
  --set githubUrl="https://github.com/empresa/projeto-b" \
  --set githubToken="ghp_xxxxxxxxxxxx" \
  --set runnerName="projeto-b-runners"
```

## ⚙️ Configurações Avançadas

### Escalabilidade
```bash
# Mais runners simultâneos
--set gha-runner-scale-set.maxRunners=20

# Sempre manter runners ativos
--set gha-runner-scale-set.minRunners=2
```

### Recursos
```bash
# Mais CPU/Memória por runner
--set gha-runner-scale-set.template.spec.containers[0].resources.limits.cpu="2000m"
--set gha-runner-scale-set.template.spec.containers[0].resources.limits.memory="4Gi"
```

---

**💡 Dica:** O controller é compartilhado entre todos os runners. Instale apenas uma vez e use para múltiplos projetos! 