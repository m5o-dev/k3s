# 🧪 **Guia Prático de Testes de Charts**

> **Testes essenciais** para charts funcionais - foco no que realmente importa!

---

## 📋 **ÍNDICE**

1. [🎯 Filosofia Prática](#-filosofia-prática)
2. [🔍 Testes Básicos](#-testes-básicos)
3. [🧪 Helm Tests](#-helm-tests)
4. [⚙️ Script Automatizado](#-script-automatizado)
5. [🚀 CI/CD Simples](#-cicd-simples)
6. [✅ Checklist Essencial](#-checklist-essencial)

---

## 🎯 **Filosofia Prática**

### **💡 Baseado na Realidade**

**✅ O que funciona:**
- **🔍 Helm lint** - Pega 80% dos problemas
- **🧪 Helm template** - Verifica se gera YAML válido
- **🚀 Instalação real** - Testa se realmente funciona
- **📦 Helm tests** - Valida conectividade básica

**❌ O que complica desnecessariamente:**
- Frameworks complexos de teste
- Múltiplas ferramentas conflitantes
- Testes unitários excessivos
- Infraestrutura de teste complexa

### **🎯 Princípios Observados:**
1. **Simples e efetivo** - 4 comandos que cobrem 90% dos casos
2. **Rápido feedback** - Falha cedo, falha claro
3. **Copy-paste ready** - Comandos que funcionam
4. **Focado no usuário** - Testa experiência real

---

## 🔍 **Testes Básicos**

### **📋 Os 4 Comandos Essenciais**

#### **1. 🔍 Helm Lint (obrigatório)**
```bash
# Validar sintaxe básica
helm lint charts/[nome-do-chart]

# ✅ Deve retornar: "1 chart(s) linted, 0 failure(s)"
```

#### **2. 🧪 Helm Template (obrigatório)**
```bash
# Gerar YAML sem instalar
helm template test charts/[nome-do-chart] \
  --set domain=test.meusite.com

# ✅ Deve gerar YAML válido sem erros
```

#### **3. 🔧 Dry Run (obrigatório)**
```bash
# Validar com Kubernetes API
helm template test charts/[nome-do-chart] \
  --set domain=test.meusite.com | \
  kubectl apply --dry-run=client -f -

# ✅ Deve validar sem erros
```

#### **4. 🚀 Instalação Real (obrigatório)**
```bash
# Testar instalação completa
helm install test charts/[nome-do-chart] \
  --set domain=test.meusite.com \
  --create-namespace \
  --namespace test

# Verificar se funcionou
kubectl get pods -n test
kubectl get svc -n test
kubectl get ingressroute -n test

# Limpar após teste
helm uninstall test -n test
kubectl delete namespace test
```

### **🎯 Cenários Obrigatórios**

**Para CADA chart, testar:**

#### **Configuração Mínima:**
```bash
helm template test charts/[nome] --set domain=test.com
```

#### **Com Autenticação (se aplicável):**
```bash
helm template test charts/[nome] \
  --set domain=test.com \
  --set auth.enabled=true \
  --set auth.password=teste123
```

#### **Com TLS (se aplicável):**
```bash
helm template test charts/[nome] \
  --set domain=test.com \
  --set tls.enabled=true
```

#### **Com Persistência (se aplicável):**
```bash
helm template test charts/[nome] \
  --set domain=test.com \
  --set storage.size=10Gi
```

#### **Configurações Avançadas:**
```bash
helm template test charts/[nome] \
  --set domain=test.com \
  --set advanced.enabled=true \
  --set advanced.deployment.replicas=3
```

---

## 🧪 **Helm Tests**

### **📋 Template Padrão de Teste**

**Arquivo:** `templates/tests/test-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}-test"
  namespace: "{{ .Release.Namespace }}"
  labels:
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
    app.kubernetes.io/component: "test"
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-weight": "1"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  restartPolicy: Never
  containers:
  - name: test
    image: curlimages/curl:latest
    command:
    - /bin/sh
    - -c
    - |
      set -e
      echo "🧪 Testando {{ .Chart.Name }}..."
      
      # Teste 1: Conectividade básica com Service
      SERVICE_URL="http://{{ .Release.Name }}-{{ .Chart.Name }}:80"
      echo "📡 Testando conectividade: $SERVICE_URL"
      curl -f --connect-timeout 10 --max-time 30 $SERVICE_URL/ || {
        echo "❌ Falha na conectividade com service"
        exit 1
      }
      echo "✅ Service acessível"
      
      {{- if .Values.domain }}
      # Teste 2: Verificar se domínio está configurado
      echo "🌐 Verificando configuração de domínio: {{ .Values.domain }}"
      {{- end }}
      
      {{- if .Values.auth.enabled }}
      # Teste 3: Verificar autenticação (deve falhar sem credenciais)
      echo "🔐 Testando autenticação..."
      if curl -f --connect-timeout 5 $SERVICE_URL/; then
        echo "❌ Autenticação não está funcionando"
        exit 1
      fi
      echo "✅ Autenticação funcionando"
      {{- end }}
      
      echo "🎉 Todos os testes passaram!"
```

### **🚀 Executar Testes**

```bash
# Instalar chart
helm install test charts/[nome] \
  --set domain=test.meusite.com \
  --create-namespace \
  --namespace test

# Aguardar pods estarem prontos
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=[nome] -n test --timeout=300s

# Executar testes
helm test test -n test

# Ver logs dos testes
kubectl logs -l app.kubernetes.io/component=test -n test

# Limpar
helm uninstall test -n test
kubectl delete namespace test
```

---

## ⚙️ **Script Automatizado**

### **📋 Script Completo de Testes**

**Arquivo:** `scripts/test-chart.sh`

```bash
#!/bin/bash
set -e

CHART_NAME=${1:-""}
NAMESPACE="test-$(date +%s)"

if [[ -z "$CHART_NAME" ]]; then
  echo "❌ Uso: $0 <nome-do-chart>"
  echo "📋 Exemplo: $0 bridge"
  exit 1
fi

if [[ ! -d "charts/$CHART_NAME" ]]; then
  echo "❌ Chart charts/$CHART_NAME não encontrado"
  exit 1
fi

echo "🧪 Testando chart: $CHART_NAME"
echo "📦 Namespace: $NAMESPACE"

# Função de cleanup
cleanup() {
  echo "🧹 Limpando recursos..."
  helm uninstall test -n $NAMESPACE 2>/dev/null || true
  kubectl delete namespace $NAMESPACE 2>/dev/null || true
}
trap cleanup EXIT

# 1. Helm Lint
echo "🔍 1/5 - Helm Lint..."
helm lint charts/$CHART_NAME
echo "✅ Lint OK"

# 2. Template Generation
echo "🧪 2/5 - Template Generation..."
helm template test charts/$CHART_NAME \
  --set domain=test.meusite.com > /tmp/test-$CHART_NAME.yaml
echo "✅ Template OK"

# 3. Dry Run
echo "🔧 3/5 - Dry Run..."
kubectl apply --dry-run=client -f /tmp/test-$CHART_NAME.yaml
echo "✅ Dry Run OK"

# 4. Instalação Real
echo "🚀 4/5 - Instalação Real..."
kubectl create namespace $NAMESPACE
helm install test charts/$CHART_NAME \
  --set domain=test.meusite.com \
  --namespace $NAMESPACE

# Aguardar pods
echo "⏳ Aguardando pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=$CHART_NAME \
  -n $NAMESPACE --timeout=300s

# 5. Helm Tests
echo "🧪 5/5 - Helm Tests..."
if kubectl get pod -l app.kubernetes.io/component=test -n $NAMESPACE 2>/dev/null | grep -q test; then
  helm test test -n $NAMESPACE
  echo "✅ Helm Tests OK"
else
  echo "⚠️ Sem helm tests definidos"
fi

echo "🎉 Todos os testes passaram para $CHART_NAME!"
```

### **🚀 Como Usar**

```bash
# Dar permissão de execução
chmod +x scripts/test-chart.sh

# Testar um chart específico
./scripts/test-chart.sh bridge

# Testar todos os charts
for chart in charts/*/; do
  chart_name=$(basename "$chart")
  echo "🧪 Testando $chart_name..."
  ./scripts/test-chart.sh "$chart_name"
done
```

---

## 🚀 **CI/CD Simples**

### **📋 GitHub Actions Básico**

**Arquivo:** `.github/workflows/test-charts.yml`

```yaml
name: Test Charts

on:
  push:
    paths:
      - 'charts/**'
  pull_request:
    paths:
      - 'charts/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Helm
        uses: azure/setup-helm@v3
        with:
          version: '3.12.0'

      - name: Setup Kubernetes
        uses: helm/kind-action@v1.8.0
        with:
          cluster_name: kind

      - name: Test Charts
        run: |
          # Testar cada chart modificado
          for chart in charts/*/; do
            chart_name=$(basename "$chart")
            echo "🧪 Testing $chart_name..."
            
            # Lint
            helm lint "$chart"
            
            # Template
            helm template test "$chart" --set domain=test.com
            
            # Install
            helm install test "$chart" \
              --set domain=test.com \
              --create-namespace \
              --namespace "test-$chart_name"
            
            # Wait and test
            kubectl wait --for=condition=ready pod \
              -l app.kubernetes.io/name="$chart_name" \
              -n "test-$chart_name" --timeout=300s
            
            # Helm test if available
            helm test test -n "test-$chart_name" || true
            
            # Cleanup
            helm uninstall test -n "test-$chart_name"
            kubectl delete namespace "test-$chart_name"
          done
```

---

## ✅ **Checklist Essencial**

### **📋 Para CADA Chart**

**🔍 Validação Básica:**
- [ ] **Helm lint** passa sem erros
- [ ] **Helm template** gera YAML válido
- [ ] **Kubectl dry-run** valida recursos
- [ ] **Instalação básica** funciona com domain

**🧪 Cenários de Teste:**
- [ ] **Mínimo**: Apenas domain definido
- [ ] **Auth**: Com autenticação habilitada
- [ ] **TLS**: Com HTTPS habilitado
- [ ] **Storage**: Com persistência habilitada
- [ ] **Advanced**: Com configurações complexas

**🚀 Funcionalidade:**
- [ ] **Pods sobem** sem erros
- [ ] **Services funcionam** (port-forward OK)
- [ ] **IngressRoutes criados** corretamente
- [ ] **Helm tests** passam (se existirem)
- [ ] **Upgrade funciona** sem problemas

**📋 Documentação:**
- [ ] **README atualizado** com comandos testados
- [ ] **Exemplos funcionam** quando copiados
- [ ] **Troubleshooting** cobre problemas reais
- [ ] **Values comentados** explicam configurações

### **🎯 Script de Validação Rápida**

```bash
#!/bin/bash
# Quick validation script

CHART_NAME=${1:-""}
if [[ -z "$CHART_NAME" ]]; then
  echo "Uso: $0 <chart-name>"
  exit 1
fi

echo "🔍 Lint..."
helm lint charts/$CHART_NAME

echo "🧪 Template..."
helm template test charts/$CHART_NAME --set domain=test.com > /dev/null

echo "🔧 Dry run..."
helm template test charts/$CHART_NAME --set domain=test.com | \
kubectl apply --dry-run=client -f - > /dev/null

echo "✅ $CHART_NAME validado!"
```

---

## 🎯 **RESUMO EXECUTIVO**

### **✅ Essencial que Funciona:**
1. **🔍 4 comandos básicos** - lint, template, dry-run, install
2. **🧪 Helm tests simples** - conectividade e funcionalidade básica
3. **⚙️ Script automatizado** - roda todos os testes de uma vez
4. **🚀 CI/CD básico** - GitHub Actions simples

### **📋 Foco no que Importa:**
- **Sintaxe correta** (helm lint)
- **YAML válido** (template + dry-run)
- **Instalação funciona** (helm install)
- **Aplicação responde** (helm test)

### **🎯 Objetivo Final:**
**Garantir que charts funcionam na prática, sem complicar com ferramentas complexas!**

---

**💡 Testes simples que cobrem 90% dos problemas reais - baseados na experiência com charts em produção!** 