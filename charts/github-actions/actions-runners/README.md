# 🏃 GitHub Actions Runners

**Self-hosted runners para executar GitHub Actions no cluster k3s.**

## 📋 Pré-requisitos

1. **Controller instalado:** O `actions-controller` deve estar rodando no cluster
2. **Token do GitHub:** Personal Access Token com permissões adequadas

## 📦 Instalação

```bash
# 1. Baixar dependências
helm dependency build

# 2. Instalar runners
helm install meus-runners . \
  --namespace github-actions \
  --create-namespace \
  --set githubUrl="https://github.com/minha-org" \
  --set githubToken="ghp_xxxxxxxxxxxx" \
  --set runnerName="meus-runners" \
  --set gha-runner-scale-set.githubConfigUrl="https://github.com/minha-org" \
  --set gha-runner-scale-set.githubConfigSecret="meus-runners-github-secret" \
  --set gha-runner-scale-set.runnerScaleSetName="meus-runners"
```

## 🔑 Token do GitHub

Crie um **Personal Access Token** com as permissões:

- **Para repositórios:** `repo`
- **Para organizações:** `admin:org`

[Criar token aqui](https://github.com/settings/tokens/new)

## 📋 Usar nos Workflows

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
          echo "Executando no k3s!"
          kubectl get nodes
```

## ⚙️ Configuração Avançada

```bash
# Mais runners simultâneos
helm upgrade meus-runners . \
  --set gha-runner-scale-set.maxRunners=20

# Sempre manter runners ativos
helm upgrade meus-runners . \
  --set gha-runner-scale-set.minRunners=2

# Recursos customizados
helm upgrade meus-runners . \
  --set gha-runner-scale-set.template.spec.containers[0].resources.limits.cpu="2000m" \
  --set gha-runner-scale-set.template.spec.containers[0].resources.limits.memory="4Gi"
```

## 🔍 Verificação

```bash
# Ver pods dos runners
kubectl get pods -n github-actions

# Ver logs do listener
kubectl logs -n github-actions deployment/meus-runners-scale-set-listener

# Verificar runners no GitHub
# Acesse: GitHub → Settings → Actions → Runners
```

## 🗑️ Desinstalar

```bash
helm uninstall meus-runners -n github-actions
kubectl delete namespace github-actions
```

---

**⚠️ Importante:** Certifique-se de que o `actions-controller` está rodando antes de instalar os runners! 