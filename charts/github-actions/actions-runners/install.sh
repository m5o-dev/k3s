#!/bin/bash

# =================================================================
# 🏃 GITHUB ACTIONS RUNNERS - INSTALAÇÃO SIMPLES
# =================================================================

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "================================================================="
echo "🏃 GITHUB ACTIONS RUNNERS - INSTALAÇÃO"
echo "================================================================="
echo ""

# Verificar se Helm está instalado
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm não encontrado. Instale o Helm primeiro.${NC}"
    exit 1
fi

# Solicitar informações
echo -e "${BLUE}📝 Configuração necessária:${NC}"
echo ""
read -p "🔗 URL do GitHub (repo ou org): " GITHUB_URL
read -p "🔑 Token do GitHub: " GITHUB_TOKEN
read -p "🏷️  Nome dos runners [k3s-runners]: " RUNNER_NAME
read -p "📦 Namespace [github-actions]: " NAMESPACE

# Valores padrão
RUNNER_NAME=${RUNNER_NAME:-"k3s-runners"}
NAMESPACE=${NAMESPACE:-"github-actions"}

if [ -z "$GITHUB_URL" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ URL e token são obrigatórios${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🚀 Instalando com:${NC}"
echo "📍 GitHub: $GITHUB_URL"
echo "🏷️  Runners: $RUNNER_NAME"
echo "📦 Namespace: $NAMESPACE"
echo ""

# Baixar dependências se necessário
if [ ! -d "charts" ]; then
    echo -e "${BLUE}📦 Baixando dependências...${NC}"
    helm dependency build
fi

# Instalar chart
echo -e "${BLUE}📦 Instalando GitHub Actions Runners...${NC}"

helm upgrade --install "$RUNNER_NAME" . \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --set githubUrl="$GITHUB_URL" \
    --set githubToken="$GITHUB_TOKEN" \
    --set runnerName="$RUNNER_NAME" \
    --set gha-runner-scale-set.githubConfigUrl="$GITHUB_URL" \
    --set gha-runner-scale-set.githubConfigSecret="$RUNNER_NAME-github-secret" \
    --set gha-runner-scale-set.runnerScaleSetName="$RUNNER_NAME" \
    --wait

echo ""
echo "================================================================="
echo -e "${GREEN}✅ GitHub Actions Runners instalados com sucesso!${NC}"
echo "================================================================="
echo ""
echo "🎯 Para usar nos workflows:"
echo ""
echo "jobs:"
echo "  exemplo:"
echo "    runs-on: $RUNNER_NAME"
echo "    steps:"
echo "      - uses: actions/checkout@v4"
echo "      - run: echo 'Executando no k3s!'"
echo ""
echo -e "${BLUE}🔍 Verificar status:${NC}"
echo "kubectl get pods -n $NAMESPACE"
echo "" 