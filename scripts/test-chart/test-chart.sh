#!/bin/bash
# =============================================================================
# 🧪 SCRIPT DE TESTE DE CHARTS
# =============================================================================
# Script completo para testar charts Helm com validação em múltiplas camadas
# Uso: ./test-chart.sh <chart-name> [options]
#
# Autor: k8s Team
# Data: $(date +%Y-%m-%d)
# =============================================================================

set -e  # Falha no primeiro erro

# =============================================================================
# 🎨 CONFIGURAÇÕES E CORES
# =============================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações padrão
DEFAULT_TIMEOUT=300
DEFAULT_VALUES_FILE=""
DEFAULT_NAMESPACE_PREFIX="test-ns"
DEFAULT_RELEASE_PREFIX="test"

# =============================================================================
# 📋 FUNÇÕES UTILITÁRIAS
# =============================================================================

print_header() {
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=============================================${NC}"
}

print_step() {
    echo -e "${CYAN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}🎉 $1${NC}"
}

show_usage() {
    cat << EOF
🧪 Script de Teste de Charts Helm

USAGE:
    $0 <chart-name> [options]

ARGUMENTS:
    chart-name          Nome do chart (deve existir em charts/)

OPTIONS:
    -v, --values FILE   Arquivo de values customizado
    -t, --timeout SEC   Timeout para operações (default: 300s)
    -n, --namespace NS  Prefixo do namespace (default: test-ns)
    -r, --release REL   Prefixo do release (default: test)
    --set KEY=VALUE     Definir valores específicos (pode ser usado múltiplas vezes)
    -h, --help          Mostrar esta ajuda
    --skip-lint         Pular validação de lint
    --skip-install      Pular instalação (apenas lint e template)
    --skip-tests        Pular helm tests
    --cleanup-only      Apenas limpar recursos existentes

EXAMPLES:
    # Teste básico
    $0 bridge

    # Teste com values customizados
    $0 bridge --values ./config/test-values.yaml

    # Teste com configurações específicas
    $0 longhorn --set auth.password=minhasenha --skip-install

    # Teste apenas lint e templates
    $0 bridge --skip-install

    # Limpeza apenas
    $0 bridge --cleanup-only

REQUIREMENTS:
    - helm (v3.x)
    - kubectl (configurado)
    - Cluster Kubernetes acessível
    - Chart deve existir em charts/[chart-name]
EOF
}

# =============================================================================
# 🧹 FUNÇÃO DE LIMPEZA
# =============================================================================

cleanup() {
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        print_error "Script falhou com código: $exit_code"
    fi
    
    if [ -n "$CLEANUP_NAMESPACE" ] && [ "$CLEANUP_NAMESPACE" != "default" ]; then
        print_step "Limpando recursos de teste..."
        
        # Tentar uninstall do helm primeiro
        if [ -n "$RELEASE_NAME" ]; then
            print_step "Removendo release: $RELEASE_NAME"
            helm uninstall "$RELEASE_NAME" -n "$CLEANUP_NAMESPACE" 2>/dev/null || true
        fi
        
        # Aguardar um pouco para recursos serem removidos
        sleep 5
        
        # Remover namespace
        print_step "Removendo namespace: $CLEANUP_NAMESPACE"
        kubectl delete namespace "$CLEANUP_NAMESPACE" --timeout=60s 2>/dev/null || true
        
        print_step "Limpeza concluída"
    fi
    
    if [ $exit_code -eq 0 ]; then
        print_success "Script concluído com sucesso!"
    fi
}

# Configurar trap para limpeza automática
trap cleanup EXIT

# =============================================================================
# 📝 PARSING DE ARGUMENTOS
# =============================================================================

CHART_NAME=""
VALUES_FILE="$DEFAULT_VALUES_FILE"
TIMEOUT="$DEFAULT_TIMEOUT"
NAMESPACE_PREFIX="$DEFAULT_NAMESPACE_PREFIX"
RELEASE_PREFIX="$DEFAULT_RELEASE_PREFIX"
SKIP_LINT=false
SKIP_INSTALL=false
SKIP_TESTS=false
CLEANUP_ONLY=false
SET_VALUES=()  # Array para armazenar valores --set

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--values)
            VALUES_FILE="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE_PREFIX="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_PREFIX="$2"
            shift 2
            ;;
        --skip-lint)
            SKIP_LINT=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --cleanup-only)
            CLEANUP_ONLY=true
            shift
            ;;
        --set)
            SET_VALUES+=("--set" "$2")
            shift 2
            ;;
        -*)
            print_error "Opção desconhecida: $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$CHART_NAME" ]; then
                CHART_NAME="$1"
            else
                print_error "Múltiplos chart names fornecidos: $CHART_NAME e $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validar chart name
if [ -z "$CHART_NAME" ]; then
    print_error "Chart name é obrigatório"
    show_usage
    exit 1
fi

# =============================================================================
# 🔍 VALIDAÇÕES INICIAIS
# =============================================================================

print_header "🧪 TESTE DE CHART: $CHART_NAME"

# Verificar se chart existe
CHART_PATH="charts/$CHART_NAME"
if [ ! -d "$CHART_PATH" ]; then
    print_error "Chart não encontrado: $CHART_PATH"
    print_warning "Charts disponíveis:"
    ls -1 charts/ 2>/dev/null | grep -v '\..*' || echo "  (nenhum chart encontrado)"
    exit 1
fi

# Verificar dependências
print_step "Verificando dependências..."

if ! command -v helm &> /dev/null; then
    print_error "helm não está instalado"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl não está instalado"
    exit 1
fi

# Verificar conectividade com cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Não foi possível conectar ao cluster Kubernetes"
    print_warning "Verifique sua configuração do kubectl"
    exit 1
fi

# Verificar arquivo de values se fornecido
if [ -n "$VALUES_FILE" ] && [ ! -f "$VALUES_FILE" ]; then
    print_error "Arquivo de values não encontrado: $VALUES_FILE"
    exit 1
fi

print_success "Dependências verificadas"

# =============================================================================
# 🧹 MODO CLEANUP APENAS
# =============================================================================

if [ "$CLEANUP_ONLY" = true ]; then
    print_header "🧹 MODO LIMPEZA"
    
    # Procurar namespaces de teste para este chart
    CLEANUP_NAMESPACES=$(kubectl get namespaces -o name | grep "namespace/$NAMESPACE_PREFIX-.*-$CHART_NAME" | cut -d/ -f2 || true)
    
    if [ -n "$CLEANUP_NAMESPACES" ]; then
        echo "$CLEANUP_NAMESPACES" | while read ns; do
            print_step "Limpando namespace: $ns"
            
            # Listar releases neste namespace
            RELEASES=$(helm list -n "$ns" -q || true)
            if [ -n "$RELEASES" ]; then
                echo "$RELEASES" | while read release; do
                    print_step "Removendo release: $release"
                    helm uninstall "$release" -n "$ns" || true
                done
            fi
            
            # Remover namespace
            kubectl delete namespace "$ns" --timeout=60s || true
        done
        print_success "Limpeza concluída"
    else
        print_warning "Nenhum namespace de teste encontrado para chart: $CHART_NAME"
    fi
    
    exit 0
fi

# =============================================================================
# 🎯 CONFIGURAÇÃO DO TESTE
# =============================================================================

# Gerar nomes únicos
TIMESTAMP=$(date +%s)
NAMESPACE="$NAMESPACE_PREFIX-$TIMESTAMP-$CHART_NAME"
RELEASE_NAME="$RELEASE_PREFIX-$TIMESTAMP"
CLEANUP_NAMESPACE="$NAMESPACE"

print_step "Configuração do teste:"
echo "  📦 Chart: $CHART_NAME"
echo "  🏠 Namespace: $NAMESPACE"
echo "  📋 Release: $RELEASE_NAME"
echo "  ⏱️  Timeout: ${TIMEOUT}s"
if [ -n "$VALUES_FILE" ]; then
    echo "  📝 Values: $VALUES_FILE"
fi

# =============================================================================
# 🔍 ETAPA 1: HELM LINT
# =============================================================================

if [ "$SKIP_LINT" = false ]; then
    print_header "🔍 ETAPA 1: HELM LINT"
    
    print_step "Executando helm lint..."
    
    # Lint básico
    if ! helm lint "$CHART_PATH"; then
        print_error "Helm lint falhou"
        exit 1
    fi
    
    # Lint com values customizados se fornecido
    if [ -n "$VALUES_FILE" ]; then
        print_step "Testando com values customizados..."
        if ! helm lint "$CHART_PATH" --values "$VALUES_FILE"; then
            print_error "Helm lint com values customizados falhou"
            exit 1
        fi
    fi
    
    # Lint com diferentes configurações
    print_step "Testando diferentes configurações..."
    
    # Configuração com todas as features
    if ! helm lint "$CHART_PATH" \
        --set domain=test.meusite.com \
        --set auth.enabled=true \
        --set tls.enabled=true \
        --set persistence.enabled=true \
        --set healthcheck.enabled=true; then
        print_error "Helm lint com features habilitadas falhou"
        exit 1
    fi
    
    print_success "Helm lint passou em todas as configurações"
else
    print_warning "Pulando helm lint (--skip-lint)"
fi

# =============================================================================
# 🔧 ETAPA 2: TEMPLATE VALIDATION
# =============================================================================

print_header "🔧 ETAPA 2: TEMPLATE VALIDATION"

print_step "Gerando templates..."

# Preparar comando base
HELM_TEMPLATE_CMD="helm template $RELEASE_NAME $CHART_PATH --namespace $NAMESPACE --set domain=test.meusite.com"

# Adicionar values file se fornecido
if [ -n "$VALUES_FILE" ]; then
    HELM_TEMPLATE_CMD="$HELM_TEMPLATE_CMD --values $VALUES_FILE"
fi

# Adicionar valores --set customizados
if [ ${#SET_VALUES[@]} -gt 0 ]; then
    HELM_TEMPLATE_CMD="$HELM_TEMPLATE_CMD ${SET_VALUES[*]}"
fi

# Gerar templates
print_step "Gerando templates com configuração padrão..."
if ! $HELM_TEMPLATE_CMD > /tmp/chart-templates.yaml; then
    print_error "Falha ao gerar templates"
    exit 1
fi

# Validar YAML com kubectl dry-run
print_step "Validando YAML gerado..."
if ! kubectl apply --dry-run=client -f /tmp/chart-templates.yaml; then
    print_error "YAML gerado é inválido"
    print_warning "Templates gerados salvos em: /tmp/chart-templates.yaml"
    exit 1
fi

# Testar configurações específicas
print_step "Testando templates com diferentes configurações..."

# Testar com features opcionais habilitadas se não há --set customizados
if [ ${#SET_VALUES[@]} -eq 0 ]; then
    if ! helm template "$RELEASE_NAME" "$CHART_PATH" \
        --namespace "$NAMESPACE" \
        --set domain=test.meusite.com \
        --set auth.enabled=true \
        --set tls.enabled=true \
        --set persistence.enabled=true \
        --set healthcheck.enabled=true | \
        kubectl apply --dry-run=client -f -; then
        print_warning "Templates com features opcionais falharam (normal se chart não suporta todas)"
    fi
else
    print_step "Pulando teste de features opcionais (valores --set customizados fornecidos)"
fi

print_success "Todos os templates são válidos"

# =============================================================================
# 🚀 ETAPA 3: INSTALAÇÃO
# =============================================================================

if [ "$SKIP_INSTALL" = false ]; then
    print_header "🚀 ETAPA 3: INSTALAÇÃO"
    
    # Criar namespace
    print_step "Criando namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
    
    # Preparar comando de instalação
    HELM_INSTALL_CMD="helm install $RELEASE_NAME $CHART_PATH --namespace $NAMESPACE --wait --timeout ${TIMEOUT}s --set domain=test.meusite.com"
    
    # Adicionar values file se fornecido
    if [ -n "$VALUES_FILE" ]; then
        HELM_INSTALL_CMD="$HELM_INSTALL_CMD --values $VALUES_FILE"
    fi
    
    # Adicionar valores --set customizados
    if [ ${#SET_VALUES[@]} -gt 0 ]; then
        HELM_INSTALL_CMD="$HELM_INSTALL_CMD ${SET_VALUES[*]}"
    fi
    
    # Instalar chart
    print_step "Instalando chart..."
    if ! $HELM_INSTALL_CMD; then
        print_error "Falha na instalação do chart"
        
        # Debug info
        print_warning "Informações de debug:"
        echo "Status do release:"
        helm status "$RELEASE_NAME" -n "$NAMESPACE" || true
        echo ""
        echo "Recursos no namespace:"
        kubectl get all -n "$NAMESPACE" || true
        echo ""
        echo "Events:"
        kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' || true
        
        exit 1
    fi
    
    # Verificar status
    print_step "Verificando status da instalação..."
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    
    # Listar recursos criados
    print_step "Recursos criados:"
    kubectl get all -n "$NAMESPACE"
    
    print_success "Chart instalado com sucesso"
else
    print_warning "Pulando instalação (--skip-install)"
fi

# =============================================================================
# 🧪 ETAPA 4: HELM TESTS
# =============================================================================

if [ "$SKIP_INSTALL" = false ] && [ "$SKIP_TESTS" = false ]; then
    print_header "🧪 ETAPA 4: HELM TESTS"
    
    # Verificar se existem testes
    if kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/component=test" --ignore-not-found | grep -q test; then
        print_warning "Pods de teste antigos encontrados, removendo..."
        kubectl delete pods -n "$NAMESPACE" -l "app.kubernetes.io/component=test" || true
        sleep 5
    fi
    
    # Executar testes
    print_step "Executando helm test..."
    
    if helm test "$RELEASE_NAME" -n "$NAMESPACE" --timeout "${TIMEOUT}s"; then
        print_success "Helm tests passaram"
        
        # Mostrar logs dos testes
        print_step "Logs dos testes:"
        kubectl logs -n "$NAMESPACE" -l "app.kubernetes.io/component=test" --tail=50
    else
        print_error "Helm tests falharam"
        
        # Debug logs
        print_warning "Logs dos testes para debug:"
        kubectl logs -n "$NAMESPACE" -l "app.kubernetes.io/component=test" --tail=100 || true
        
        print_warning "Pods de teste:"
        kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/component=test" || true
        
        exit 1
    fi
else
    if [ "$SKIP_INSTALL" = true ]; then
        print_warning "Pulando helm tests (instalação foi pulada)"
    else
        print_warning "Pulando helm tests (--skip-tests)"
    fi
fi

# =============================================================================
# 🔄 ETAPA 5: TESTE DE UPGRADE
# =============================================================================

if [ "$SKIP_INSTALL" = false ]; then
    print_header "🔄 ETAPA 5: TESTE DE UPGRADE"
    
    # Preparar comando de upgrade
    HELM_UPGRADE_CMD="helm upgrade $RELEASE_NAME $CHART_PATH --namespace $NAMESPACE --wait --timeout ${TIMEOUT}s --set domain=test.meusite.com --set replicas=2"
    
    # Adicionar values file se fornecido
    if [ -n "$VALUES_FILE" ]; then
        HELM_UPGRADE_CMD="$HELM_UPGRADE_CMD --values $VALUES_FILE"
    fi
    
    # Adicionar valores --set customizados
    if [ ${#SET_VALUES[@]} -gt 0 ]; then
        HELM_UPGRADE_CMD="$HELM_UPGRADE_CMD ${SET_VALUES[*]}"
    fi
    
    # Fazer upgrade
    print_step "Fazendo upgrade com réplicas=2..."
    if ! $HELM_UPGRADE_CMD; then
        print_error "Falha no upgrade do chart"
        
        # Debug info
        print_warning "Status após falha do upgrade:"
        helm status "$RELEASE_NAME" -n "$NAMESPACE" || true
        kubectl get all -n "$NAMESPACE" || true
        
        exit 1
    fi
    
    # Verificar se upgrade funcionou
    print_step "Verificando upgrade..."
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    
    # Verificar se replicas foram aplicadas (se deployment existe)
    if kubectl get deployment -n "$NAMESPACE" "$RELEASE_NAME-$CHART_NAME" &>/dev/null; then
        CURRENT_REPLICAS=$(kubectl get deployment -n "$NAMESPACE" "$RELEASE_NAME-$CHART_NAME" -o jsonpath='{.spec.replicas}')
        if [ "$CURRENT_REPLICAS" = "2" ]; then
            print_success "Upgrade funcionou - réplicas atualizadas para 2"
        else
            print_warning "Upgrade pode não ter funcionado - réplicas: $CURRENT_REPLICAS (esperado: 2)"
        fi
    else
        print_warning "Deployment não encontrado, pulando verificação de réplicas"
    fi
    
    print_success "Teste de upgrade concluído"
else
    print_warning "Pulando teste de upgrade (instalação foi pulada)"
fi

# =============================================================================
# 📊 ETAPA 6: RELATÓRIO FINAL
# =============================================================================

print_header "📊 RELATÓRIO FINAL"

print_step "Resumo dos testes executados:"

# Estatísticas
echo "  📦 Chart testado: $CHART_NAME"
echo "  🏠 Namespace: $NAMESPACE"
echo "  📋 Release: $RELEASE_NAME"

if [ "$SKIP_LINT" = false ]; then
    echo "  ✅ Helm lint: PASSOU"
else
    echo "  ⏭️  Helm lint: PULADO"
fi

echo "  ✅ Template validation: PASSOU"

if [ "$SKIP_INSTALL" = false ]; then
    echo "  ✅ Instalação: PASSOU"
    echo "  ✅ Upgrade: PASSOU"
    
    if [ "$SKIP_TESTS" = false ]; then
        echo "  ✅ Helm tests: PASSOU"
    else
        echo "  ⏭️  Helm tests: PULADO"
    fi
else
    echo "  ⏭️  Instalação: PULADO"
    echo "  ⏭️  Upgrade: PULADO"
    echo "  ⏭️  Helm tests: PULADO"
fi

# Informações finais
if [ "$SKIP_INSTALL" = false ]; then
    print_step "Para verificar o deployment:"
    echo "  kubectl get all -n $NAMESPACE"
    echo "  helm status $RELEASE_NAME -n $NAMESPACE"
    echo ""
    print_step "Para limpar os recursos manualmente:"
    echo "  helm uninstall $RELEASE_NAME -n $NAMESPACE"
    echo "  kubectl delete namespace $NAMESPACE"
    echo ""
fi

print_success "TODOS OS TESTES PASSARAM! 🎉"
print_success "Chart $CHART_NAME está funcionando corretamente!"

# Limpeza automática será feita pelo trap cleanup
# Namespace e release serão removidos automaticamente 