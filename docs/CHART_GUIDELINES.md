# 📋 **CHART GUIDELINES - FILOSOFIA E ESTRUTURA**

> **Definições fundamentais** para criação de charts Helm simples e amigáveis

---

## 📋 **ÍNDICE**

1. [🎯 Objetivo e Filosofia](#-objetivo-e-filosofia)
2. [🏗️ Estrutura de um Chart](#-estrutura-de-um-chart)
3. [📝 Padrões Obrigatórios](#-padrões-obrigatórios)
4. [🔧 Templates Padrão](#-templates-padrão)
5. [✅ Checklist de Qualidade](#-checklist-de-qualidade)
6. [📚 Documentação Relacionada](#-documentação-relacionada)

---

## 🎯 **Objetivo e Filosofia**

### **🎯 Missão**
Criar charts Helm **simples e amigáveis** para pessoas aprendendo Kubernetes. O foco é na **experiência do usuário iniciante**, mantendo a simplicidade sem comprometer a funcionalidade.

### **💡 Princípios Fundamentais**

#### **1. 🚀 Simplicidade Primeiro**
- **Templates diretos** sem abstrações desnecessárias
- **Values.yaml limpo** com o que realmente importa no topo
- **Sem _helpers.tpl** - mantém tudo visível e legível
- **Documentação abundante** inline nos templates e values

#### **2. 🎓 Educacional**
- **Aprenda fazendo** - templates servem como exemplos
- **Comentários explicativos** em português
- **Padrões consistentes** que ensinam boas práticas
- **README didático** com exemplos práticos

#### **3. 🔧 Funcionais desde o Primeiro Momento**
- **Defaults sensatos** que funcionam out-of-the-box
- **Configuração mínima** obrigatória (apenas domain)
- **Features opcionais** bem definidas
- **Compatibilidade** com Traefik por padrão

#### **4. 📈 Escaláveis**
- **Configurações avançadas** disponíveis mas opcionais
- **Padrões enterprise** quando necessário
- **Fácil migração** para charts mais complexos
- **Manutenção simplificada**

---

## 🏗️ **Estrutura de um Chart**

### **📁 Diretório Padrão**
```
new-charts/nome-do-chart/
├── Chart.yaml              # Metadados do chart
├── values.yaml             # Configurações (ver CHART_NAMING_STANDARDS.md)
├── README.md               # Documentação focada no usuário
├── templates/
│   ├── deployment.yaml     # Aplicação principal
│   ├── service.yaml        # Exposição interna
│   ├── ingressroute.yaml   # Exposição externa (Traefik)
│   ├── configmap.yaml      # Configurações (se necessário)
│   ├── secret.yaml         # Credenciais (se necessário)
│   ├── pvc.yaml           # Armazenamento (se necessário)
│   ├── rbac.yaml          # Permissões (se necessário)
│   └── tests/
│       └── test-pod.yaml   # Testes funcionais
└── .helmignore             # Arquivos a ignorar
```

### **🎯 Templates Obrigatórios**
- ✅ **Deployment**: Aplicação principal
- ✅ **Service**: Exposição interna 
- ✅ **IngressRoute**: Exposição externa (Traefik)

### **🔧 Templates Opcionais**
- 🔐 **Secret**: Apenas se auth ou TLS habilitado
- 📋 **ConfigMap**: Apenas se configurações customizadas
- 💾 **PVC**: Apenas se persistência habilitada
- 👤 **RBAC**: Apenas se permissões específicas necessárias

---

## 📝 **Padrões Obrigatórios**

### **📋 Chart.yaml**
```yaml
apiVersion: v2
name: nome-do-chart
description: "Descrição clara do que o chart faz (máx 160 chars)"
type: application
version: 0.1.0            # Versão do chart (semver)
appVersion: "1.0.0"       # Versão da aplicação
keywords:
  - kubernetes
  - web
  - application
home: https://github.com/seu-usuario/charts
sources:
  - https://github.com/aplicacao-oficial
maintainers:
  - name: "Seu Nome"
    email: "seu@email.com"
```

### **🏷️ Labels e Nomenclatura**
**Ver documentação completa:** [`docs/CHART_NAMING_STANDARDS.md`](./CHART_NAMING_STANDARDS.md)

**Resumo essencial:**
- ✅ **6 labels obrigatórias** em TODOS os recursos
- ✅ **Nome padrão**: `{{ .Release.Name }}-{{ .Chart.Name }}`
- ✅ **Seletores**: Apenas `name` e `instance`
- ❌ **NUNCA usar** `_helpers.tpl` - mantém simplicidade

### **📝 Values.yaml**
**Ver estrutura completa:** [`docs/CHART_NAMING_STANDARDS.md#estrutura-valuesyaml`](./CHART_NAMING_STANDARDS.md#estrutura-valuesyaml)

**Ordem obrigatória:**
1. **🚀 CONFIGURAÇÃO ESSENCIAL** (domain, image, resources)
2. **⚡ FUNCIONALIDADES OPCIONAIS** (auth, tls, persistence)
3. **🔧 CONFIGURAÇÃO AVANÇADA** (advanced.enabled=false por padrão)

---

## 🔧 **Templates Padrão**

### **🎯 Filosofia de Templates**
- **Simplicidade máxima** - sem _helpers.tpl
- **Copy/paste friendly** - labels repetidas mas visíveis
- **Educacional** - cada template ensina boas práticas
- **Funcional** - defaults que funcionam sem configuração

### **📦 Deployment (Essencial)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    # 6 labels obrigatórias (ver CHART_NAMING_STANDARDS.md)
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
    app.kubernetes.io/part-of: "{{ .Chart.Name }}"
    app.kubernetes.io/managed-by: "{{ .Release.Service }}"
spec:
  replicas: {{ .Values.replicas | default 1 }}
  selector:
    matchLabels:
      # Apenas 2 labels para seletores
      app.kubernetes.io/name: "{{ .Chart.Name }}"
      app.kubernetes.io/instance: "{{ .Release.Name }}"
  template:
    metadata:
      labels:
        # Mesmas 6 labels do metadata
        app.kubernetes.io/name: "{{ .Chart.Name }}"
        app.kubernetes.io/instance: "{{ .Release.Name }}"
        app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
        app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
        app.kubernetes.io/part-of: "{{ .Chart.Name }}"
        app.kubernetes.io/managed-by: "{{ .Release.Service }}"
    spec:
      containers:
      - name: "{{ .Chart.Name }}"
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" | quote }}
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        {{- with .Values.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        # Health checks opcionais (ver CHART_HEALTH_CHECKS.md)
        {{- if .Values.healthcheck.enabled }}
        {{- if .Values.healthcheck.liveness.enabled }}
        livenessProbe:
          httpGet:
            path: {{ .Values.healthcheck.liveness.path | default "/health" | quote }}
            port: http
          initialDelaySeconds: {{ .Values.healthcheck.liveness.initialDelaySeconds | default 30 }}
          periodSeconds: {{ .Values.healthcheck.liveness.periodSeconds | default 10 }}
        {{- end }}
        {{- if .Values.healthcheck.readiness.enabled }}
        readinessProbe:
          httpGet:
            path: {{ .Values.healthcheck.readiness.path | default "/ready" | quote }}
            port: http
          initialDelaySeconds: {{ .Values.healthcheck.readiness.initialDelaySeconds | default 5 }}
          periodSeconds: {{ .Values.healthcheck.readiness.periodSeconds | default 5 }}
        {{- end }}
        {{- end }}
```

### **🌐 Service (Essencial)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    # Mesmas 6 labels obrigatórias
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
    app.kubernetes.io/part-of: "{{ .Chart.Name }}"
    app.kubernetes.io/managed-by: "{{ .Release.Service }}"
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: http
    protocol: TCP
    name: http
  selector:
    # Mesmas 2 labels do selector
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
```

### **🚪 IngressRoute (Essencial)**
```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    # Mesmas 6 labels obrigatórias
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
    app.kubernetes.io/part-of: "{{ .Chart.Name }}"
    app.kubernetes.io/managed-by: "{{ .Release.Service }}"
spec:
  entryPoints:
  - web
  {{- if .Values.tls.enabled }}
  - websecure
  {{- end }}
  routes:
  - match: "Host(`{{ .Values.domain }}`)"
    kind: Rule
    services:
    - name: "{{ .Release.Name }}-{{ .Chart.Name }}"
      port: 80
    {{- if .Values.auth.enabled }}
    middlewares:
    - name: "{{ .Release.Name }}-{{ .Chart.Name }}-auth"
    {{- end }}
  {{- if .Values.tls.enabled }}
  tls:
    certResolver: "letsencrypt"
  {{- end }}
```

### **📋 Templates de Exemplo**
**Ver templates completos:** [`docs/examples/`](./examples/)

---

## ✅ **Checklist de Qualidade**

### **📋 Validação Básica**
- [ ] **Chart.yaml**: Todos os campos obrigatórios preenchidos
- [ ] **Labels**: Todas as 6 labels kubernetes.io em TODOS os recursos
- [ ] **Nomes**: `{{ .Release.Name }}-{{ .Chart.Name }}` consistente
- [ ] **Seletores**: Apenas `name` e `instance` (não `version` ou `component`)
- [ ] **Values**: Estrutura Essencial → Opcional → Avançado
- [ ] **Comentários**: Explicativos e educativos no values.yaml
- [ ] **Defaults**: Funcionam out-of-the-box
- [ ] **README**: Documentação clara com exemplos

### **🧪 Validação de Testes**
**Ver checklist completo:** [`docs/TESTING_STRATEGY.md#checklist-obrigatório`](./TESTING_STRATEGY.md#6-checklist-de-testes-obrigatórios)

- [ ] **Helm Lint**: `helm lint` passa sem erros
- [ ] **Template Generation**: `helm template` gera YAML válido  
- [ ] **Dry Run**: `kubectl apply --dry-run=client` funciona
- [ ] **Helm Test**: Templates de teste implementados
- [ ] **Install**: Chart instala corretamente
- [ ] **Upgrade**: Chart faz upgrade sem problemas

### **🎯 Validação de Experiência**
- [ ] **Comando Básico**: `helm install test chart --set domain=app.com` funciona
- [ ] **Features**: Todas as funcionalidades testadas
- [ ] **Health Checks**: Implementados quando apropriado
- [ ] **Troubleshooting**: Documentado no CHART_TROUBLESHOOTING.md

---

## 📚 **Documentação Relacionada**

### **📋 Padrões e Nomenclatura**
- **[CHART_NAMING_STANDARDS.md](./CHART_NAMING_STANDARDS.md)** - Labels, nomenclatura, estrutura de values
- **[CHART_VALUES_GUIDE.md](./CHART_VALUES_GUIDE.md)** - Padrões específicos de configuração

### **🔧 Implementação e Exemplos**
- **[examples/](./examples/)** - Templates de referência prontos para usar
- **[CHART_HEALTH_CHECKS.md](./CHART_HEALTH_CHECKS.md)** - Implementação de health checks

### **🧪 Testes e Qualidade**
- **[CHART_TESTING_GUIDE.md](./CHART_TESTING_GUIDE.md)** - Estratégia completa de testes
- **[scripts/test-chart/](../scripts/test-chart/)** - Scripts automatizados de teste
- **[CHART_TROUBLESHOOTING.md](./CHART_TROUBLESHOOTING.md)** - Guia de resolução de problemas

### **🚀 Processo de Desenvolvimento**
1. **Criar chart** seguindo este guideline
2. **Aplicar padrões** de CHART_NAMING_STANDARDS.md
3. **Testar completamente** com CHART_TESTING_GUIDE.md
4. **Documentar adequadamente** no README do chart

---

## 🎯 **RESUMO EXECUTIVO**

### **✅ O que SEMPRE fazer:**
- ✅ **6 labels obrigatórias** em todos os recursos
- ✅ **Nomes consistentes** com padrão definido
- ✅ **Values estruturados** em 3 seções (essencial/opcional/avançado)
- ✅ **Templates diretos** sem _helpers.tpl
- ✅ **Comentários educativos** abundantes
- ✅ **Testes implementados** (helm tests)
- ✅ **README didático** com exemplos

### **❌ O que NUNCA fazer:**
- ❌ **_helpers.tpl** - mantém simplicidade
- ❌ **Labels inconsistentes** - seguir padrão rigoroso
- ❌ **Values complexos** no topo - essencial primeiro
- ❌ **Templates obscuros** - tudo deve ser legível
- ❌ **Defaults quebrados** - deve funcionar out-of-the-box
- ❌ **Documentação pobre** - explicar tudo claramente

### **🎓 Filosofia em 3 palavras:**
**SIMPLES. EDUCATIVO. FUNCIONAL.**

---

**💡 Lembre-se:** O objetivo é ensinar Kubernetes através de charts que funcionam, não impressionar com complexidade técnica! 