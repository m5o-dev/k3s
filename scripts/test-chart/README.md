# 🧪 **SCRIPT DE TESTE DE CHARTS**

> **Ferramenta completa** para testar charts Helm com validação em múltiplas camadas

---

## 📋 **ÍNDICE**

1. [🚀 Introdução](#-introdução)
2. [⚙️ Instalação](#-instalação)
3. [🎯 Uso Básico](#-uso-básico)
4. [🔧 Opções Avançadas](#-opções-avançadas)
5. [📋 Exemplos](#-exemplos)
6. [🧪 Etapas de Teste](#-etapas-de-teste)
7. [🛠️ Configuração](#-configuração)
8. [🚨 Troubleshooting](#-troubleshooting)

---

## 🚀 **Introdução**

O `test-chart.sh` é um script completo que automatiza todo o processo de validação de charts Helm, desde lint básico até testes funcionais em cluster real.

### **🎯 Funcionalidades**

- ✅ **Helm Lint**: Validação de sintaxe e estrutura
- ✅ **Template Validation**: Geração e validação de YAML
- ✅ **Instalação**: Deploy em namespace temporário
- ✅ **Helm Tests**: Execução de testes funcionais
- ✅ **Upgrade Testing**: Validação de upgrades
- ✅ **Cleanup Automático**: Limpeza automática de recursos
- ✅ **Debug Info**: Informações detalhadas em caso de falha

### **🏗️ Arquitetura de Testes**

```
🔍 Lint → 🔧 Templates → 🚀 Install → 🧪 Tests → 🔄 Upgrade → 🧹 Cleanup
  ↓           ↓            ↓           ↓          ↓          ↓
 Sintaxe   YAML Válido  Deploy OK   Funcional  Upgrade OK  Limpo
```

---

## ⚙️ **Instalação**

### **📋 Pré-requisitos**

1. **Helm v3.x**
   ```bash
   # macOS
   brew install helm
   
   # Linux
   curl https://get.helm.sh/helm-v3.12.1-linux-amd64.tar.gz | tar xz
   sudo mv linux-amd64/helm /usr/local/bin/
   ```

2. **kubectl configurado**
   ```bash
   # Verificar conectividade
   kubectl cluster-info
   kubectl get nodes
   ```

3. **Cluster Kubernetes acessível**
   - Minikube, k3d, k3s, EKS, GKE, AKS, etc.
   - Permissões para criar namespaces
   - Permissões para instalar charts

### **🔧 Setup**

```bash
# 1. Tornar script executável (já feito)
chmod +x scripts/test-chart/test-chart.sh

# 2. Verificar se está funcionando
./scripts/test-chart/test-chart.sh --help

# 3. Testar chart existente
./scripts/test-chart/test-chart.sh bridge
```

---

## 🎯 **Uso Básico**

### **📋 Sintaxe**

```bash
./scripts/test-chart/test-chart.sh <chart-name> [options]
```

### **🚀 Comandos Essenciais**

```bash
# Teste completo (recomendado)
./scripts/test-chart/test-chart.sh bridge

# Teste apenas lint e templates (rápido)
./scripts/test-chart/test-chart.sh bridge --skip-install

# Teste com timeout customizado
./scripts/test-chart/test-chart.sh bridge --timeout 600

# Limpeza de recursos antigos
./scripts/test-chart/test-chart.sh bridge --cleanup-only
```

### **📊 Output Típico**

```bash
🧪 TESTE DE CHART: bridge
=============================================
✅ Verificando dependências...
✅ Dependências verificadas

🔍 ETAPA 1: HELM LINT
=============================================
✅ Executando helm lint...
✅ Testando diferentes configurações...
🎉 Helm lint passou em todas as configurações

🔧 ETAPA 2: TEMPLATE VALIDATION
=============================================
✅ Gerando templates...
✅ Validando YAML gerado...
✅ Testando templates com diferentes configurações...
🎉 Todos os templates são válidos

🚀 ETAPA 3: INSTALAÇÃO
=============================================
✅ Criando namespace: test-ns-1691234567-bridge
✅ Instalando chart...
✅ Verificando status da instalação...
🎉 Chart instalado com sucesso

🧪 ETAPA 4: HELM TESTS
=============================================
✅ Executando helm test...
🎉 Helm tests passaram

🔄 ETAPA 5: TESTE DE UPGRADE
=============================================
✅ Fazendo upgrade com réplicas=2...
✅ Verificando upgrade...
🎉 Teste de upgrade concluído

📊 RELATÓRIO FINAL
=============================================
✅ Resumo dos testes executados:
  📦 Chart testado: bridge
  🏠 Namespace: test-ns-1691234567-bridge
  📋 Release: test-1691234567
  ✅ Helm lint: PASSOU
  ✅ Template validation: PASSOU
  ✅ Instalação: PASSOU
  ✅ Upgrade: PASSOU
  ✅ Helm tests: PASSOU

🎉 TODOS OS TESTES PASSARAM! 🎉
🎉 Chart bridge está funcionando corretamente!
```

---

## 🔧 **Opções Avançadas**

### **📋 Lista Completa de Opções**

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-v, --values FILE` | Arquivo de values customizado | `--values ./config/prod.yaml` |
| `-t, --timeout SEC` | Timeout para operações (default: 300s) | `--timeout 600` |
| `-n, --namespace NS` | Prefixo do namespace (default: test-ns) | `--namespace ci-test` |
| `-r, --release REL` | Prefixo do release (default: test) | `--release mytest` |
| `--skip-lint` | Pular validação de lint | `--skip-lint` |
| `--skip-install` | Pular instalação (apenas lint e template) | `--skip-install` |
| `--skip-tests` | Pular helm tests | `--skip-tests` |
| `--cleanup-only` | Apenas limpar recursos existentes | `--cleanup-only` |
| `-h, --help` | Mostrar ajuda | `--help` |

### **🎯 Cenários de Uso**

#### **Desenvolvimento Rápido (apenas sintaxe)**
```bash
./scripts/test-chart/test-chart.sh bridge --skip-install
# ✅ Lint + Template validation (30 segundos)
```

#### **CI/CD Pipeline (completo)**
```bash
./scripts/test-chart/test-chart.sh bridge --timeout 600
# ✅ Todos os testes (5-10 minutos)
```

#### **Debug de Chart (sem timeout)**
```bash
./scripts/test-chart/test-chart.sh bridge --timeout 0 --skip-tests
# ✅ Instala e deixa rodando para debug manual
```

#### **Limpeza de Recursos**
```bash
./scripts/test-chart/test-chart.sh bridge --cleanup-only
# ✅ Remove todos os namespaces de teste antigos
```

---

## 📋 **Exemplos**

### **🔧 Configuração com Values Customizados**

**1. Criar arquivo de values para teste:**
```bash
# scripts/test-chart/config/test-values.yaml
domain: "test.exemplo.com"
auth:
  enabled: true
  username: "admin"
  password: "secret123"
tls:
  enabled: true
persistence:
  enabled: true
  size: "2Gi"
healthcheck:
  enabled: true
  liveness:
    enabled: true
    path: "/health"
  readiness:
    enabled: true
    path: "/ready"
```

**2. Executar teste:**
```bash
./scripts/test-chart/test-chart.sh bridge \
  --values ./scripts/test-chart/config/test-values.yaml \
  --timeout 600
```

### **🤖 Integração com CI/CD**

**GitHub Actions exemplo:**
```yaml
- name: Test Charts
  run: |
    for chart in charts/*/; do
      chart_name=$(basename "$chart")
      echo "Testing chart: $chart_name"
      ./scripts/test-chart/test-chart.sh "$chart_name" --timeout 600
    done
```

### **🔄 Teste em Loop (Múltiplos Charts)**

```bash
#!/bin/bash
# Testar todos os charts disponíveis

for chart in charts/*/; do
    chart_name=$(basename "$chart")
    echo "🧪 Testando chart: $chart_name"
    
    if ./scripts/test-chart/test-chart.sh "$chart_name"; then
        echo "✅ $chart_name: PASSOU"
    else
        echo "❌ $chart_name: FALHOU"
        exit 1
    fi
    
    echo "----------------------------------------"
done

echo "🎉 Todos os charts passaram nos testes!"
```

---

## 🧪 **Etapas de Teste**

### **🔍 Etapa 1: Helm Lint**

**O que testa:**
- Sintaxe básica dos templates
- Estrutura do Chart.yaml
- Values.yaml bem formado
- Templates geram YAML válido

**Configurações testadas:**
- Values padrão
- Values customizados (se fornecido)
- Todas as features habilitadas
- Diferentes combinações de flags

### **🔧 Etapa 2: Template Validation**

**O que testa:**
- Templates geram YAML válido
- YAML é aceito pelo Kubernetes (dry-run)
- Diferentes configurações de values
- Recursos têm campos obrigatórios

**Validações:**
- `helm template` executa sem erro
- `kubectl apply --dry-run=client` aceita o YAML
- Templates funcionam com features opcionais

### **🚀 Etapa 3: Instalação**

**O que testa:**
- Chart instala em cluster real
- Recursos são criados corretamente
- Pods ficam em estado Running
- Services são criados e funcionais

**Processo:**
1. Criar namespace temporário
2. Instalar chart com `--wait`
3. Verificar status com `helm status`
4. Listar recursos criados

### **🧪 Etapa 4: Helm Tests**

**O que testa:**
- Funcionalidade da aplicação
- Conectividade entre recursos
- Health checks funcionam
- Autenticação funciona (se habilitada)

**Baseado em:**
- Templates em `templates/tests/`
- Pods com annotation `helm.sh/hook: test`
- Ver: [`docs/examples/test-pod.yaml`](../docs/examples/test-pod.yaml)

### **🔄 Etapa 5: Upgrade Testing**

**O que testa:**
- Chart pode ser atualizado
- Upgrade funciona sem downtime
- Configurações são aplicadas
- Recursos são atualizados corretamente

**Processo:**
1. Fazer upgrade com `replicas=2`
2. Verificar se upgrade foi aplicado
3. Confirmar que aplicação continua funcionando

### **🧹 Etapa 6: Cleanup**

**Automático:**
- Remove release com `helm uninstall`
- Deleta namespace temporário
- Aguarda recursos serem removidos
- Executado mesmo se script falhar (trap)

---

## 🛠️ **Configuração**

### **📁 Estrutura de Arquivos**

```
scripts/test-chart/
├── test-chart.sh              # Script principal
├── README.md                  # Esta documentação
└── config/
    ├── test-values.yaml      # Values para testes
    └── environments/
        ├── dev.yaml          # Config para dev
        ├── staging.yaml      # Config para staging
        └── prod.yaml         # Config para prod
```

### **⚙️ Configuração de Values**

**Criar values específicos para teste:**
```bash
# scripts/test-chart/config/test-values.yaml
domain: "test.local"

# Usar recursos mínimos para testes
resources:
  requests:
    memory: "32Mi"
    cpu: "25m"
  limits:
    memory: "64Mi"
    cpu: "50m"

# Habilitar features para teste completo
auth:
  enabled: true
  username: "testuser"
  password: "testpass"

healthcheck:
  enabled: true
  liveness:
    enabled: true
  readiness:
    enabled: true

# Persistência com storage pequeno
persistence:
  enabled: true
  size: "100Mi"
```

### **🔧 Variáveis de Ambiente**

O script suporta variáveis de ambiente:

```bash
# Configurar defaults globalmente
export TEST_CHART_TIMEOUT=600
export TEST_CHART_NAMESPACE_PREFIX="ci-test"
export TEST_CHART_RELEASE_PREFIX="ci"

# Executar teste
./scripts/test-chart/test-chart.sh bridge
```

---

## 🚨 **Troubleshooting**

### **❌ Problemas Comuns**

#### **1. Chart não encontrado**
```
❌ Chart não encontrado: charts/meuapp
```

**Solução:**
```bash
# Verificar charts disponíveis
ls -la charts/

# Usar nome correto
./scripts/test-chart/test-chart.sh bridge  # não 'meuapp'
```

#### **2. Cluster não acessível**
```
❌ Não foi possível conectar ao cluster Kubernetes
```

**Solução:**
```bash
# Verificar kubectl
kubectl cluster-info
kubectl get nodes

# Configurar context se necessário
kubectl config use-context my-cluster
```

#### **3. Timeout na instalação**
```
❌ Falha na instalação do chart
```

**Solução:**
```bash
# Aumentar timeout
./scripts/test-chart/test-chart.sh bridge --timeout 900

# Debug manual
kubectl get all -n test-ns-xxx-bridge
kubectl describe pod -n test-ns-xxx-bridge
kubectl logs -n test-ns-xxx-bridge deployment/xxx
```

#### **4. Helm tests falhando**
```
❌ Helm tests falharam
```

**Solução:**
```bash
# Ver logs detalhados
kubectl logs -n test-ns-xxx-bridge -l app.kubernetes.io/component=test

# Testar conectividade manual
kubectl exec -n test-ns-xxx-bridge deployment/xxx -- curl localhost:80

# Pular testes temporariamente
./scripts/test-chart/test-chart.sh bridge --skip-tests
```

### **🔍 Debug Avançado**

#### **Manter recursos para debug**
```bash
# Instalar sem cleanup automático
./scripts/test-chart/test-chart.sh bridge --skip-tests &
PID=$!

# Em outro terminal, debug manual
kubectl get all -n test-ns-xxx-bridge
helm status test-xxx -n test-ns-xxx-bridge

# Limpar quando terminar
kill $PID
./scripts/test-chart/test-chart.sh bridge --cleanup-only
```

#### **Salvar logs para análise**
```bash
# Executar com redirecionamento
./scripts/test-chart/test-chart.sh bridge 2>&1 | tee test-output.log

# Analisar logs
grep "❌\|ERROR\|FAILED" test-output.log
```

### **🛠️ Configurações de Debug**

```bash
# Modo verbose (adicionar set -x no script)
sed -i '3a set -x' scripts/test-chart/test-chart.sh

# Executar com debug
./scripts/test-chart/test-chart.sh bridge

# Remover debug
sed -i '/set -x/d' scripts/test-chart/test-chart.sh
```

---

## 🎯 **Integração com TESTING_STRATEGY.md**

Este script implementa as estratégias definidas em [`docs/TESTING_STRATEGY.md`](../docs/TESTING_STRATEGY.md):

- ✅ **Múltiplas camadas** de validação
- ✅ **Automatização total** do processo
- ✅ **Feedback rápido** com logs detalhados
- ✅ **Cleanup automático** para evitar sujeira
- ✅ **Flexibilidade** com múltiplas opções

**Para estratégias avançadas de teste, consulte:**
- [`docs/TESTING_STRATEGY.md`](../docs/TESTING_STRATEGY.md) - Metodologia completa
- [`docs/examples/test-pod.yaml`](../docs/examples/test-pod.yaml) - Template de helm tests

---

**💡 Use este script como parte do seu fluxo de desenvolvimento para garantir que todos os charts funcionem corretamente antes de fazer commit!** 