# 🧪 **ESTRATÉGIA DE TESTES E VALIDAÇÃO**

> **Metodologia completa** para garantir qualidade e confiabilidade dos charts

---

## 📋 **ÍNDICE**

1. [📋 Filosofia de Testes](#-filosofia-de-testes)
2. [🔍 Validação de Sintaxe](#-1-validação-de-sintaxe)
3. [🧪 Helm Tests](#-2-helm-tests-testes-funcionais)
4. [⚙️ Chart Testing](#-3-chart-testing-ct)
5. [🔄 Testes de Integração](#-4-testes-de-integração)
6. [🚀 CI/CD Integration](#-5-cicd-integration)
7. [📋 Checklist Obrigatório](#-6-checklist-de-testes-obrigatórios)
8. [🛠️ Ferramentas Recomendadas](#-7-ferramentas-recomendadas)
9. [🎯 Métricas de Qualidade](#-8-métricas-de-qualidade)

---

## 📋 **Filosofia de Testes**

### **🎯 Princípios Fundamentais**
- **🚀 Teste cedo e frequentemente**: Validar a cada mudança
- **⚙️ Automatização total**: Scripts para CI/CD
- **📊 Múltiplas camadas**: Sintaxe → Funcionalidade → Integração
- **⚡ Feedback rápido**: Falhas devem ser identificadas rapidamente
- **🔒 Confiabilidade**: Testes devem ser determinísticos
- **📚 Documentação viva**: Testes também servem como documentação

### **🏗️ Pirâmide de Testes**

```
    🔄 Testes de Integração (poucos)
         ↑ Instalação completa em cluster
         ↑ Teste end-to-end com dependências
         ↑ Simulação de ambiente real

  🧪 Testes Funcionais (alguns)
       ↑ Helm tests em pods
       ↑ Verificação de conectividade
       ↑ Health checks e endpoints

🔍 Testes de Sintaxe (muitos)
     ↑ Helm lint
     ↑ Template validation
     ↑ YAML syntax check
     ↑ Dry-run validation
```

---

## 🔍 **1. VALIDAÇÃO DE SINTAXE**

### **📋 Helm Lint (Obrigatório)**

**Validação básica:**
```bash
# Validar sintaxe básica do chart
helm lint new-charts/[nome-do-chart]

# Validar com diferentes values
helm lint new-charts/[nome-do-chart] \
  --values new-charts/[nome-do-chart]/values.yaml

# Validar com configurações específicas
helm lint new-charts/[nome-do-chart] \
  --set domain=test.com \
  --set auth.enabled=true \
  --set tls.enabled=true \
  --set persistence.enabled=true
```

**Critérios de Aceite:**
- ✅ **Zero erros** de lint
- ✅ **Zero warnings críticos**
- ✅ **Todas as combinações** de values testadas

---

### **🔧 Template Validation**

**Gerar e validar templates:**
```bash
# Gerar templates sem instalar
helm template test-release new-charts/[nome-do-chart] \
  --set domain=test.exemplo.com

# Validar YAML gerado com kubectl
helm template test-release new-charts/[nome-do-chart] \
  --set domain=test.exemplo.com | kubectl apply --dry-run=client -f -

# Testar cenários específicos
helm template test-release new-charts/[nome-do-chart] \
  --set domain=test.exemplo.com \
  --set auth.enabled=true \
  --set tls.enabled=true \
  --set persistence.enabled=true
```

**Cenários de Teste Obrigatórios:**
- 🎯 **Configuração mínima** (apenas domain)
- 🔐 **Com autenticação** (auth.enabled=true)
- 🔒 **Com TLS** (tls.enabled=true)
- 💾 **Com persistência** (persistence.enabled=true)
- 🩺 **Com health checks** (healthcheck.enabled=true)
- 🔧 **Configurações avançadas** (advanced.enabled=true)

---

## 🧪 **2. HELM TESTS (Testes Funcionais)**

### **📋 Estrutura de Test Templates**

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
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/component: "test"
    app.kubernetes.io/part-of: "{{ .Chart.Name }}"
    app.kubernetes.io/managed-by: "{{ .Release.Service }}"
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
      echo "🧪 Iniciando testes do {{ .Chart.Name }}..."
      
      # Teste 1: Conectividade com Service
      SERVICE_URL="http://{{ .Release.Name }}-{{ .Chart.Name }}:80"
      curl -f --connect-timeout 10 $SERVICE_URL/ || exit 1
      
      {{- if .Values.domain }}
      # Teste 2: Verificar IngressRoute
      nslookup {{ .Values.domain }} || echo "⚠️ DNS não configurado"
      {{- end }}
      
      {{- if .Values.auth.enabled }}
      # Teste 3: Verificar autenticação
      curl -f $SERVICE_URL/ && exit 1 || echo "✅ Auth OK"
      {{- end }}
      
      {{- if .Values.healthcheck.enabled }}
      # Teste 4: Health checks
      {{- if .Values.healthcheck.liveness.enabled }}
      curl -f "$SERVICE_URL{{ .Values.healthcheck.liveness.path | default "/health" }}" || exit 1
      {{- end }}
      {{- end }}
      
      echo "🎉 Todos os testes passaram!"
```

### **🚀 Executar Helm Tests**

```bash
# Instalar chart
helm install test-release new-charts/[nome-do-chart] \
  --set domain=test.exemplo.com

# Executar testes
helm test test-release

# Ver logs detalhados dos testes
kubectl logs -l app.kubernetes.io/component=test

# Executar testes específicos
helm test test-release --filter name=test-connectivity

# Limpar após testes
helm uninstall test-release
```

### **📝 Template de Exemplo**

Ver arquivo completo: [`docs/examples/test-pod.yaml`](./examples/test-pod.yaml)

---

## ⚙️ **3. CHART TESTING (ct)**

### **🔧 Instalação**

```bash
# macOS
brew install chart-testing

# Linux - Download direto
curl -sSL https://github.com/helm/chart-testing/releases/download/v3.10.1/chart-testing_3.10.1_linux_amd64.tar.gz | tar xz
sudo mv ct /usr/local/bin/

# Verificar instalação
ct version
```

### **⚙️ Configuração**

**Arquivo:** `.github/ct.yaml`

```yaml
# Configuração do chart-testing
remote: origin
target-branch: main
chart-dirs:
  - new-charts
chart-repos:
  - bitnami=https://charts.bitnami.com/bitnami
helm-extra-args: --timeout 600s
check-version-increment: false
debug: true
validate-maintainers: false
```

### **📋 Comandos de Validação**

```bash
# Listar charts modificados
ct list-changed --config .github/ct.yaml

# Lint de charts específicos
ct lint --config .github/ct.yaml --charts new-charts/bridge

# Lint de todos os charts modificados
ct lint --config .github/ct.yaml

# Instalar e testar charts
ct install --config .github/ct.yaml --charts new-charts/bridge

# Teste completo (lint + install)
ct lint-and-install --config .github/ct.yaml
```

---

## 🔄 **4. TESTES DE INTEGRAÇÃO**

### **📁 Estrutura de Scripts**

Ver documentação completa: [`scripts/test-chart/README.md`](../scripts/test-chart/README.md)

```
scripts/
└── test-chart/
    ├── test-chart.sh          # Script principal
    ├── README.md              # Documentação
    └── config/
        ├── test-values.yaml   # Values para teste
        └── environments/      # Configs por ambiente
```

### **🚀 Uso Básico**

```bash
# Testar chart específico
./scripts/test-chart/test-chart.sh bridge

# Testar com values customizados
./scripts/test-chart/test-chart.sh bridge --values ./config/test-values.yaml

# Testar todos os charts
for chart in new-charts/*/; do
  chart_name=$(basename "$chart")
  ./scripts/test-chart/test-chart.sh "$chart_name"
done
```

### **📋 Funcionalidades do Script**

- ✅ **Helm lint** automático
- ✅ **Template validation** com dry-run
- ✅ **Instalação** em namespace temporário
- ✅ **Helm tests** automatizados
- ✅ **Upgrade testing** com diferentes configs
- ✅ **Cleanup automático** com trap
- ✅ **Logs detalhados** de cada etapa

---

## 🚀 **5. CI/CD INTEGRATION**

### **🤖 GitHub Actions**

**Arquivo:** `.github/workflows/test-charts.yml`

```yaml
name: Test Charts

on:
  pull_request:
    branches: [ main ]
    paths: [ 'new-charts/**' ]
  push:
    branches: [ main ]
    paths: [ 'new-charts/**' ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Set up Helm
      uses: azure/setup-helm@v3
      with:
        version: v3.12.1

    - name: Setup chart-testing
      uses: helm/chart-testing-action@v2.6.1

    - name: Create k3s cluster
      uses: nolar/setup-k3d-k3s@v1
      with:
        version: v1.27
        github-token: ${{ secrets.GITHUB_TOKEN }}

    - name: Run chart-testing (list-changed)
      id: list-changed
      run: |
        changed=$(ct list-changed --config .github/ct.yaml)
        if [[ -n "$changed" ]]; then
          echo "changed=true" >> $GITHUB_OUTPUT
        fi

    - name: Run chart-testing (lint)
      run: ct lint --config .github/ct.yaml

    - name: Run chart-testing (install)
      run: ct install --config .github/ct.yaml
      if: steps.list-changed.outputs.changed == 'true'
```

### **🔄 Pipeline Stages**

1. **🔍 Lint Stage**: Validação de sintaxe
2. **🧪 Test Stage**: Helm tests em cluster temporário
3. **📦 Package Stage**: Empacotamento dos charts
4. **🚀 Deploy Stage**: Deploy para repositório (apenas main)

### **📊 Relatórios de Qualidade**

```yaml
- name: Generate Test Report
  run: |
    ct lint --config .github/ct.yaml --print-config
    ct list-changed --config .github/ct.yaml
  
- name: Upload Test Results
  uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: test-results/
```

---

## 📋 **6. CHECKLIST DE TESTES OBRIGATÓRIOS**

### **🚧 Antes de Criar PR**

- [ ] **Helm Lint**: `helm lint` passa sem erros
- [ ] **Template Generation**: `helm template` gera YAML válido
- [ ] **Dry Run**: `kubectl apply --dry-run=client` funciona
- [ ] **Values Padrão**: Templates funcionam com values padrão
- [ ] **Features Habilitadas**: Templates funcionam com todas as features
- [ ] **README Atualizado**: Documentação tem exemplos atualizados
- [ ] **Helm Test Implementado**: Templates de teste existem e funcionam
- [ ] **Naming Standards**: Segue padrões de nomenclatura

### **✅ Antes de Merge**

- [ ] **CI/CD Passa**: Todos os testes automatizados passam
- [ ] **Install Limpo**: Chart instala em cluster limpo
- [ ] **Upgrade Funciona**: Chart faz upgrade corretamente
- [ ] **Uninstall Completo**: Chart é removido completamente
- [ ] **Documentação**: Toda documentação está atualizada
- [ ] **Breaking Changes**: Documentados se existirem
- [ ] **Security Scan**: Sem vulnerabilidades conhecidas

### **🔄 Testes de Regressão**

- [ ] **Backward Compatibility**: Compatibilidade mantida
- [ ] **Migration Guide**: Atualizado se necessário
- [ ] **Performance**: Sem degradação de performance
- [ ] **Resource Usage**: Recursos não aumentaram significativamente

---

## 🛠️ **7. FERRAMENTAS RECOMENDADAS**

### **🔍 Validação Local**

#### **kubeval - Validar YAML Kubernetes**
```bash
# Instalar
brew install kubeval

# Usar
helm template test new-charts/bridge --set domain=test.com | kubeval
```

#### **kube-score - Análise de Melhores Práticas**
```bash
# Instalar
brew install kube-score

# Usar
helm template test new-charts/bridge --set domain=test.com | kube-score score -
```

#### **helm-docs - Gerar Documentação Automática**
```bash
# Instalar
brew install norwoodj/tap/helm-docs

# Gerar docs
helm-docs new-charts/bridge
```

#### **pluto - Detectar APIs Deprecated**
```bash
# Instalar
brew install FairwindsOps/tap/pluto

# Verificar
helm template test new-charts/bridge --set domain=test.com | pluto detect -
```

### **📊 Monitoramento de Qualidade**

#### **Verificar Labels Obrigatórias**
```bash
helm template test new-charts/bridge --set domain=test.com | \
  yq e 'select(.metadata.labels."app.kubernetes.io/name" == null) | .kind + "/" + .metadata.name' -
```

#### **Verificar Naming Consistency**
```bash
helm template test new-charts/bridge --set domain=test.com | \
  yq e '.metadata.name' - | grep -v "test-bridge" || echo "✅ Naming OK"
```

#### **Verificar Seletores**
```bash
helm template test new-charts/bridge --set domain=test.com | \
  yq e 'select(.spec.selector.matchLabels."app.kubernetes.io/version") | "❌ Version in selector: " + .kind + "/" + .metadata.name' -
```

### **🔧 Scripts de Automação**

#### **Teste Completo Local**
```bash
#!/bin/bash
# scripts/validate-chart.sh

CHART=$1
echo "🧪 Validando chart: $CHART"

# 1. Helm lint
helm lint new-charts/$CHART

# 2. Template validation
helm template test new-charts/$CHART --set domain=test.com | kubectl apply --dry-run=client -f -

# 3. Security scan
helm template test new-charts/$CHART --set domain=test.com | kube-score score -

# 4. Check deprecated APIs
helm template test new-charts/$CHART --set domain=test.com | pluto detect -

echo "✅ Validação completa!"
```

---

## 🎯 **8. MÉTRICAS DE QUALIDADE**

### **📊 Métricas Obrigatórias**

| Métrica | Target | Medição |
|---------|--------|---------|
| **✅ Lint Score** | 100% sem erros | `helm lint` exit code 0 |
| **✅ Test Coverage** | Helm tests implementados | Arquivo `templates/tests/` existe |
| **✅ Install Success** | 100% em cluster limpo | CI/CD install stage |
| **✅ Upgrade Success** | 100% sem downtime | CI/CD upgrade test |
| **✅ Documentation** | README atualizado | Manual review |

### **⚡ Métricas Avançadas**

| Métrica | Target | Como Medir |
|---------|--------|------------|
| **⚡ Install Time** | < 60 segundos | `time helm install` |
| **🔄 Upgrade Time** | < 30 segundos | `time helm upgrade` |
| **📦 Chart Size** | < 50KB comprimido | `helm package` size |
| **🏷️ Label Compliance** | 100% dos recursos | Script de verificação |
| **🔒 Security Score** | kube-score > 8/10 | `kube-score score` |

### **📈 Relatórios de Qualidade**

#### **Dashboard de Métricas**
```bash
# Gerar relatório de qualidade
./scripts/quality-report.sh bridge

# Saída esperada:
# ✅ Lint Score: 100%
# ✅ Test Coverage: Implemented
# ✅ Install Success: OK (45s)
# ✅ Upgrade Success: OK (12s)
# ✅ Chart Size: 23KB
# ✅ Security Score: 9.2/10
# ✅ Label Compliance: 100%
```

#### **Histórico de Qualidade**
- 📊 **Trending**: Métricas ao longo do tempo
- 🚨 **Alertas**: Degradação de qualidade
- 📈 **Benchmarks**: Comparação entre charts

---

## 🎯 **RESUMO EXECUTIVO**

### **🚀 Fluxo de Testes Completo**

1. **👨‍💻 Desenvolvimento Local**:
   ```bash
   helm lint new-charts/meu-chart
   helm template test new-charts/meu-chart --set domain=test.com | kubectl apply --dry-run=client -f -
   ```

2. **🧪 Testes Funcionais**:
   ```bash
   helm install test new-charts/meu-chart --set domain=test.com
   helm test test
   ```

3. **🤖 CI/CD Automático**:
   - Lint em todas as modificações
   - Install/upgrade em cluster temporário
   - Relatórios de qualidade

4. **✅ Validação Final**:
   - Todas as métricas de qualidade atingidas
   - Documentação atualizada
   - Testes de regressão passando

### **💡 Benefícios**

- ✅ **Confiabilidade**: Charts funcionam consistentemente
- ✅ **Manutenibilidade**: Problemas detectados cedo
- ✅ **Produtividade**: Feedback rápido para desenvolvedores
- ✅ **Qualidade**: Padrões mantidos automaticamente

---

**💡 Lembre-se:** Testes não são apenas para encontrar bugs, mas para garantir uma **experiência consistente e confiável** para todos os usuários dos nossos charts! 