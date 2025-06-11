# 🏷️ **PADRÕES DE NOMENCLATURA E LABELS**

> **Definições obrigatórias** para manter consistência em todos os charts

---

## 📋 **ÍNDICE**

1. [🏷️ Labels Obrigatórias](#-labels-obrigatórias)
2. [📛 Nomenclatura Padrão](#-nomenclatura-padrão)
3. [🔧 Seletores](#-seletores)
4. [📝 Estrutura values.yaml](#-estrutura-valuesyaml)
5. [🔧 Configurações Avançadas](#-configurações-avançadas-opcionais)
6. [💬 Comentários Educativos](#-comentários-educativos)
7. [🚨 Sintaxe Correta do Helm](#-sintaxe-correta-do-helm)

---

## 🏷️ **Labels Obrigatórias**

**TODOS os recursos** devem ter estas **6 labels** obrigatórias:

```yaml
labels:
  app.kubernetes.io/name: "{{ .Chart.Name }}"
  app.kubernetes.io/instance: "{{ .Release.Name }}"
  app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
  app.kubernetes.io/part-of: "{{ .Chart.Name }}"
  app.kubernetes.io/managed-by: "{{ .Release.Service }}"
```

### **📋 Explicação das Labels**

| Label | Valor | Propósito |
|-------|-------|-----------|
| `app.kubernetes.io/name` | `{{ .Chart.Name }}` | Nome da aplicação |
| `app.kubernetes.io/instance` | `{{ .Release.Name }}` | Nome único da instância |
| `app.kubernetes.io/version` | `{{ .Chart.AppVersion }}` | Versão da aplicação |
| `app.kubernetes.io/component` | `{{ .Values.component }}` | Componente (application, database, etc.) |
| `app.kubernetes.io/part-of` | `{{ .Chart.Name }}` | Sistema maior do qual faz parte |
| `app.kubernetes.io/managed-by` | `{{ .Release.Service }}` | Ferramenta que gerencia (Helm) |

### **⚠️ Regras Críticas**

- ✅ **Obrigatório em TODOS os recursos** (Deployment, Service, IngressRoute, PVC, etc.)
- ✅ **Metadata E template** devem ter as mesmas labels
- ✅ **Use | quote** para strings dinâmicas
- ❌ **NUNCA omitir** nenhuma das 6 labels

---

## 📛 **Nomenclatura Padrão**

### **🏷️ Nome dos Recursos**
**Padrão obrigatório:**
```yaml
name: "{{ .Release.Name }}-{{ .Chart.Name }}"
```

**Exemplos:**
- Release: `meu-site`, Chart: `bridge` → Nome: `meu-site-bridge`
- Release: `api-prod`, Chart: `webapp` → Nome: `api-prod-webapp`

### **🏠 Namespace**
```yaml
namespace: "{{ .Release.Namespace }}"
```

### **📋 Exemplos por Tipo de Recurso**

#### **Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    # ... 6 labels obrigatórias
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: "{{ .Chart.Name }}"
      app.kubernetes.io/instance: "{{ .Release.Name }}"
  template:
    metadata:
      labels:
        # ... mesmas 6 labels obrigatórias
```

#### **Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    # ... 6 labels obrigatórias
spec:
  selector:
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
```

#### **IngressRoute**
```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    # ... 6 labels obrigatórias
spec:
  routes:
  - match: "Host(`{{ .Values.domain }}`)"
    services:
    - name: "{{ .Release.Name }}-{{ .Chart.Name }}"
```

---

## 🔧 **Seletores**

### **📋 Seletores Obrigatórios**
Use **SEMPRE** estas 2 labels para seletores:

```yaml
selector:
  matchLabels:
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
```

### **⚠️ Por que apenas 2 labels?**
- ✅ **Deployment** → **Service**: Conexão garantida
- ✅ **Upgrades**: Funcionam sem conflito
- ✅ **Múltiplas instâncias**: Isolamento correto
- ❌ **Não use** `version` ou `component` em seletores

---

## 📝 **Estrutura values.yaml**

### **📋 Ordem Obrigatória**

```yaml
# =================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# Configurações básicas necessárias para funcionamento
# =================================================================

# Domínio onde a aplicação será acessível
# Exemplo: app.meusite.com
domain: "app.meusite.com"

# Configuração da imagem Docker
image:
  repository: "nginx"
  tag: "1.21"
  pullPolicy: "IfNotPresent"

# Recursos computacionais
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"

# =================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# Features que podem ser habilitadas/desabilitadas
# =================================================================

# Autenticação básica
auth:
  enabled: false
  username: ""
  password: ""

# HTTPS com certificados automáticos
tls:
  enabled: false

# Armazenamento persistente
persistence:
  enabled: false
  size: "1Gi"
  storageClass: ""

# Verificações de saúde
healthcheck:
  enabled: false
  liveness:
    enabled: false
    path: "/health"
  readiness:
    enabled: false
    path: "/ready"

# =================================================================
# 🔧 CONFIGURAÇÃO AVANÇADA (OPCIONAL)
# ⚠️ Esta seção pode ser omitida por padrão do values.yaml
# Só é aplicada nos templates se advanced.enabled=true for definido
# =================================================================

advanced:
  enabled: false           # Habilita configurações avançadas nos templates
  annotations: {}          # Annotations extras para recursos
  labels: {}              # Labels extras para recursos
  nodeSelector: {}        # Seleção de nós específicos
  tolerations: []         # Tolerâncias para taints
  affinity: {}           # Regras de afinidade

# Componente da aplicação (usado nas labels)
component: "application"

# Número de réplicas (padrão: 1)
replicas: 1
```

### **🎯 Regras de Estrutura**

1. **🚀 ESSENCIAL primeiro** - Configurações que todo chart precisa
2. **⚡ OPCIONAIS segundo** - Features que podem ser desabilitadas
3. **🔧 AVANÇADAS último** - Configurações para usuários experientes
4. **💬 Comentários obrigatórios** - Explicar cada seção
5. **📋 Exemplos sempre** - Mostrar valores esperados

---

## 🔧 **Configurações Avançadas Opcionais**

### **📋 Filosofia**
- **Por padrão**: O `values.yaml` deve ser **limpo e simples**
- **Quando necessário**: Usuário adiciona `advanced.enabled=true`
- **Nos templates**: Use condicionais `{{- if .Values.advanced.enabled }}`

### **🔄 Estrutura nos Templates**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  
  # Labels principais (sempre aplicadas)
  labels:
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
    app.kubernetes.io/part-of: "{{ .Chart.Name }}"
    app.kubernetes.io/managed-by: "{{ .Release.Service }}"
    
    # Labels extras (apenas se advanced.enabled)
    {{- if .Values.advanced.enabled }}
    {{- with .Values.advanced.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- end }}
  
  # Annotations (apenas se advanced.enabled)  
  {{- if .Values.advanced.enabled }}
  {{- with .Values.advanced.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}

spec:
  # ... resto do spec
  template:
    spec:
      # Node selector (apenas se advanced.enabled)
      {{- if .Values.advanced.enabled }}
      {{- with .Values.advanced.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      # Tolerations (apenas se advanced.enabled)
      {{- with .Values.advanced.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      
      # Affinity (apenas se advanced.enabled)
      {{- with .Values.advanced.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
```

### **💡 Exemplo de Uso**

**Values.yaml simples (padrão):**
```yaml
domain: "app.meusite.com"
image:
  repository: nginx
  tag: "1.21"
```

**Usuário avançado pode adicionar:**
```yaml
domain: "app.meusite.com"
image:
  repository: nginx
  tag: "1.21"

# Habilitar configurações avançadas
advanced:
  enabled: true
  annotations:
    custom.io/annotation: "value"
    monitoring.io/scrape: "true"
  labels:
    environment: "production"
    team: "backend"
  nodeSelector:
    node-type: "compute"
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "backend"
    effect: "NoSchedule"
```

---

## 💬 **Comentários Educativos**

### **📋 Padrão de Comentários**

```yaml
# =================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# Configurações básicas necessárias para funcionamento
# =================================================================

# Domínio onde a aplicação será acessível
# Exemplo: app.meusite.com, api.empresa.com
# ⚠️ OBRIGATÓRIO: Sem domínio a aplicação não será acessível
domain: "app.meusite.com"

# Configuração da imagem Docker
# repository: Nome da imagem (sem tag)
# tag: Versão específica da imagem  
# pullPolicy: Quando baixar a imagem (IfNotPresent recomendado)
image:
  repository: "nginx"          # Imagem base
  tag: "1.21"                 # Versão estável
  pullPolicy: "IfNotPresent"  # Otimiza downloads

# Recursos computacionais
# requests: Recursos garantidos (reservados)
# limits: Recursos máximos (não pode ultrapassar)
# 💡 Comece com valores baixos e ajuste conforme necessário
resources:
  requests:
    memory: "64Mi"    # RAM garantida
    cpu: "50m"        # CPU garantida (0.05 core)
  limits:
    memory: "128Mi"   # RAM máxima
    cpu: "100m"       # CPU máxima (0.1 core)
```

### **🎯 Regras de Comentários**

1. **📋 Seções com emojis** - Facilita navegação visual
2. **💡 Explicar propósito** - Por que existe cada configuração
3. **⚠️ Alertas importantes** - Destacar configurações críticas
4. **📝 Exemplos práticos** - Mostrar valores reais
5. **🔧 Dicas de configuração** - Como ajustar para diferentes cenários

---

## 🚨 **Sintaxe Correta do Helm**

### **❌ ERRADO - Aspas Duplas Aninhadas**
```yaml
app.kubernetes.io/version: "{{ .Chart.AppVersion | quote }}"
app.kubernetes.io/component: "{{ .Values.component | default \"application\" }}"
```

### **✅ CORRETO - Use | quote**
```yaml
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
```

### **📋 Outros Padrões Corretos**

#### **Numbers/Booleans - sem aspas**
```yaml
replicas: {{ .Values.replicas | default 1 }}
enabled: {{ .Values.feature.enabled | default false }}
```

#### **Strings simples - com aspas**
```yaml
name: "{{ .Release.Name }}-{{ .Chart.Name }}"
namespace: "{{ .Release.Namespace }}"
```

#### **Values condicionais - use toYaml**
```yaml
{{- with .Values.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}

{{- with .Values.advanced.labels }}
  {{- toYaml . | nindent 4 }}
{{- end }}
```

#### **Condicionais complexas**
```yaml
# Verificar se valor existe E não está vazio
{{- if and .Values.auth.enabled .Values.auth.username }}
# Fazer algo
{{- end }}

# Verificar múltiplas condições
{{- if or .Values.tls.enabled .Values.auth.enabled }}
# Fazer algo
{{- end }}
```

#### **Default values seguros**
```yaml
# String com fallback
component: {{ .Values.component | default "application" | quote }}

# Number com fallback
replicas: {{ .Values.replicas | default 1 }}

# Boolean com fallback
enabled: {{ .Values.feature.enabled | default false }}

# Object vazio como fallback
{{- with .Values.resources | default dict }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
```

---

## 🎯 **Checklist de Nomenclatura**

### **📋 Validação Obrigatória**

- [ ] **Labels**: Todas as 6 labels kubernetes.io em TODOS os recursos
- [ ] **Nomes**: `{{ .Release.Name }}-{{ .Chart.Name }}` consistente
- [ ] **Seletores**: Apenas `name` e `instance` (não `version` ou `component`)
- [ ] **Namespace**: `{{ .Release.Namespace }}` em todos os recursos
- [ ] **Sintaxe**: Use `| quote` em strings dinâmicas
- [ ] **Values**: Estrutura Essencial → Opcional → Avançado
- [ ] **Comentários**: Explicativos e educativos no values.yaml

### **🔍 Comandos de Verificação**

```bash
# Verificar se todos os recursos têm labels obrigatórias
helm template test charts/[chart] --set domain=test.com | \
  yq e 'select(.metadata.labels."app.kubernetes.io/name" == null) | .kind + "/" + .metadata.name' -

# Verificar naming consistency
helm template test charts/[chart] --set domain=test.com | \
  yq e '.metadata.name' - | grep -v "test-[chart]" || echo "✅ Naming OK"

# Verificar seletores
helm template test charts/[chart] --set domain=test.com | \
  yq e 'select(.spec.selector.matchLabels."app.kubernetes.io/version") | "❌ Version in selector: " + .kind + "/" + .metadata.name' -
```

---

**💡 Lembre-se:** Consistência na nomenclatura é **fundamental** para operação, debugging e automação! 