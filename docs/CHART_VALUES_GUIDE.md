# ⚙️ **Guia Prático de Values.yaml**

> **Padrões funcionais** baseados nos charts Bridge, MinIO e Redis - copy-paste ready!

---

## 📋 **ÍNDICE**

1. [🎯 Filosofia Prática](#-filosofia-prática)
2. [📋 Estrutura Padrão](#-estrutura-padrão)
3. [🎨 Templates por Tipo](#-templates-por-tipo)
4. [💬 Comentários Funcionais](#-comentários-funcionais)
5. [🔧 Configurações Avançadas](#-configurações-avançadas)
6. [✅ Checklist de Qualidade](#-checklist-de-qualidade)

---

## 🎯 **Filosofia Prática**

### **💡 Baseado em Charts Reais**

**✅ O que funciona** (observado nos charts existentes):
- **🚀 Instalação em 30 segundos** - Domain + password = funcionando
- **📊 3 seções claras** - ESSENCIAL → OPCIONAL → AVANÇADO  
- **💬 Comentários educativos** - Explicam quando usar
- **🔧 advanced.enabled=false** - Complexidade opcional

**❌ O que não funciona:**
- Values complexos no topo
- Configurações obrigatórias perdidas no meio
- Comentários técnicos sem contexto
- Estrutura inconsistente entre charts

### **🎯 Princípios Observados:**
1. **Domain sempre primeiro** - Para aplicações web
2. **Image sempre presente** - Repository + tag + pullPolicy
3. **Resources simples** - CPU e memory diretos
4. **Funcionalidades opcionais** - auth, tls, persistence
5. **Advanced opcional** - enabled=false por padrão

---

## 📋 **Estrutura Padrão**

### **🎨 Template Universal (testado e aprovado)**

```yaml
# 🎯 [Nome do Chart] - Configurações Helm Chart
# Descrição breve e clara do que o chart faz

# =============================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# =============================================================================
# Estas são as configurações que 80% dos usuários vão alterar

# Domínio onde a aplicação será acessível
# Exemplo: app.meusite.com, api.empresa.com
domain: "app.exemplo.com"

# Configuração da imagem Docker
image:
  repository: nginx          # Repositório da imagem
  tag: "1.21"               # Versão/tag da imagem
  pullPolicy: IfNotPresent  # Política de download (IfNotPresent, Always, Never)

# Recursos de CPU e Memória
resources:
  cpu: "100m"     # CPU: 100m = 0.1 core, 1000m = 1 core
  memory: "128Mi" # Memória: 128Mi = 128 Megabytes, 1Gi = 1024Mi

# =============================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# =============================================================================
# Funcionalidades que podem ser habilitadas conforme necessário

# Configuração TLS/HTTPS
tls:
  enabled: false # Habilita HTTPS automático

# Configuração de autenticação
auth:
  enabled: false    # Habilita autenticação básica
  username: "admin" # Usuário padrão
  password: ""      # Senha (obrigatória se auth habilitado)

# Armazenamento persistente
storage:
  size: "10Gi"           # Tamanho do volume
  storageClass: ""       # Classe de armazenamento (vazio = padrão)

# =============================================================================
# 🔧 CONFIGURAÇÃO AVANÇADA (OPCIONAL)
# =============================================================================
# Configurações para usuários experientes (raramente alteradas)

# Sobrescrever nomes dos recursos
nameOverride: ""     # Sobrescreve o nome do chart
fullnameOverride: "" # Sobrescreve o nome completo dos recursos

# Componente para identificação nos labels
component: "application" # Tipo de componente (application, database, cache)

# Configurações extremamente avançadas (apenas se necessário)
advanced:
  enabled: false # Habilita seção de configurações avançadas

  # ⚠️ Configurações abaixo só são aplicadas se advanced.enabled=true

  # Configurações de deployment
  deployment:
    replicas: 1
    strategy:
      type: RollingUpdate

  # Configurações do service
  service:
    type: ClusterIP
    annotations: {}

  # Configurações de segurança
  security:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000

  # Variáveis de ambiente personalizadas
  env: []
  # Exemplo:
  # env:
  #   - name: CUSTOM_VAR
  #     value: "custom-value"
```

---

## 🎨 **Templates por Tipo**

### **🌐 Aplicação Web (como Bridge)**

```yaml
# 🌉 Bridge - Configurações Helm Chart
# Ponte que permite acesso remoto ao cluster via token

# =============================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# =============================================================================

domain: "bridge.exemplo.com"

image:
  repository: bitnami/kubectl
  tag: "latest"
  pullPolicy: IfNotPresent

resources:
  cpu: "100m"
  memory: "128Mi"

# =============================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# =============================================================================

tls:
  enabled: false

# ServiceAccount específico para Bridge
serviceAccount:
  create: true
  createToken: true
  automount: true
  annotations: {}

# =============================================================================
# 🔧 CONFIGURAÇÃO AVANÇADA (OPCIONAL)
# =============================================================================

nameOverride: ""
fullnameOverride: ""
component: "bridge"
port: 8001  # Porta específica do kubectl proxy

advanced:
  enabled: false
  # Configurações específicas do bridge...
```

### **💾 Aplicação com Dados (como MinIO)**

```yaml
# 🗂️ MinIO - Configurações Helm Chart
# Servidor de armazenamento de objetos S3-compatível

# =============================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# =============================================================================

# Domínios para API e Console
domains:
  api: "s3.exemplo.com"      # API S3 (para SDKs)
  console: "minio.exemplo.com" # Interface web

# Configuração da imagem
image:
  repository: quay.io/minio/minio
  tag: "RELEASE.2025-04-22T22-12-26Z"
  pullPolicy: IfNotPresent

# Credenciais obrigatórias
auth:
  username: "admin"    # Usuário root
  password: ""         # DEVE ser definido

# =============================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# =============================================================================

tls:
  enabled: false

# Armazenamento
storage:
  size: "30Gi"
  storageClass: "longhorn"

# =============================================================================
# 🔧 CONFIGURAÇÃO AVANÇADA (OPCIONAL)
# =============================================================================

nameOverride: ""
fullnameOverride: ""
component: "object-storage"

advanced:
  enabled: false
  minio:
    image:
      repository: quay.io/minio/minio
      tag: "RELEASE.2025-04-22T22-12-26Z"
    server:
      env: {}
    health:
      liveness:
        enabled: true
      readiness:
        enabled: true
```

### **🔴 Cache/Banco (como Redis)**

```yaml
# 🔴 Redis - Configurações Helm Chart
# Cache Redis in-memory para desenvolvimento e produção

# =============================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# =============================================================================

# Credenciais obrigatórias
auth:
  password: ""  # DEVE ser definido

# Configuração da imagem
image:
  repository: redis
  tag: "7.4.1-alpine"
  pullPolicy: IfNotPresent

# Recursos específicos para cache
resources:
  limits:
    cpu: "500m"
    memory: "1Gi"

# =============================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# =============================================================================

# Configurações específicas do Redis
redis:
  maxMemory: "768mb"
  maxMemoryPolicy: "allkeys-lru"
  appendOnly: true
  appendFsync: "everysec"

# Armazenamento (opcional para cache)
persistence:
  enabled: true
  size: "2Gi"
  storageClass: ""

# =============================================================================
# 🔧 CONFIGURAÇÃO AVANÇADA (OPCIONAL)
# =============================================================================

nameOverride: ""
fullnameOverride: ""
component: "cache"

advanced:
  enabled: false
  redis:
    config:
      maxClients: 10000
      timeout: 0
      tcpKeepAlive: 300
    health:
      liveness:
        enabled: true
      readiness:
        enabled: true
```

---

## 💬 **Comentários Funcionais**

### **🎯 Padrão de Comentários (baseado nos charts reais)**

```yaml
# =============================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# =============================================================================
# Estas são as configurações que 80% dos usuários vão alterar

# Domínio onde a aplicação será acessível
# Exemplo: app.meusite.com, api.empresa.com
# ⚠️ OBRIGATÓRIO: Sem domínio a aplicação não será acessível externamente
domain: "app.exemplo.com"

# Configuração da imagem Docker
image:
  repository: nginx          # Repositório da imagem (sem tag)
  tag: "1.21"               # Versão específica da imagem
  pullPolicy: IfNotPresent  # Quando baixar: IfNotPresent (recomendado), Always, Never

# Recursos computacionais
# requests: Recursos garantidos (reservados)
# limits: Recursos máximos (não pode ultrapassar)
# 💡 Comece com valores baixos e ajuste conforme necessário
resources:
  cpu: "100m"     # CPU: 100m = 0.1 core, 1000m = 1 core
  memory: "128Mi" # Memória: 128Mi = 128 Megabytes, 1Gi = 1024Mi
```

### **🔧 Seções Funcionais**

**✅ ESSENCIAL - O que 80% dos usuários alteram:**
- `domain` - Primeiro sempre (aplicações web)
- `image` - Repository + tag + pullPolicy
- `resources` - CPU e memory simples
- `auth.password` - Se aplicação tem autenticação

**⚡ OPCIONAL - Features que podem ser habilitadas:**
- `tls.enabled` - HTTPS automático
- `auth.enabled` - Autenticação básica
- `persistence.enabled` - Armazenamento
- `healthcheck.enabled` - Health checks

**🔧 AVANÇADO - Para usuários experientes:**
- `nameOverride` - Customização de nomes
- `component` - Tipo do componente
- `advanced.enabled` - Configurações complexas

---

## 🔧 **Configurações Avançadas**

### **📋 Padrão advanced.enabled=false**

```yaml
# Configurações extremamente avançadas (apenas se necessário)
advanced:
  enabled: false # Por padrão, desabilitado

  # ⚠️ Configurações abaixo só são aplicadas se advanced.enabled=true

  # Deployment específico
  deployment:
    replicas: 1
    strategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1
        maxSurge: 1

  # Service específico
  service:
    type: ClusterIP
    port: 80
    annotations: {}

  # Segurança do container
  security:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    runAsNonRoot: true

  # Health checks detalhados
  health:
    liveness:
      enabled: true
      path: "/health"
      initialDelaySeconds: 30
      periodSeconds: 10
      failureThreshold: 3
    readiness:
      enabled: true
      path: "/ready"
      initialDelaySeconds: 5
      periodSeconds: 5
      failureThreshold: 3

  # Configurações de rede
  network:
    ingress:
      annotations: {}
      middlewares: []

  # Variáveis de ambiente customizadas
  env: []
  # Exemplo:
  # env:
  #   - name: LOG_LEVEL
  #     value: "debug"
  #   - name: API_KEY
  #     valueFrom:
  #       secretKeyRef:
  #         name: api-secrets
  #         key: key

  # Volumes adicionais
  volumes: []
  volumeMounts: []
```

### **🎯 Como Usar Advanced**

```bash
# Básico (advanced desabilitado)
helm install app charts/meu-chart \
  --set domain=app.com \
  --set auth.password=senha123

# Com configurações avançadas
helm install app charts/meu-chart \
  --set domain=app.com \
  --set auth.password=senha123 \
  --set advanced.enabled=true \
  --set advanced.deployment.replicas=3 \
  --set advanced.health.liveness.enabled=true
```

---

## ✅ **Checklist de Qualidade**

### **📋 Para Values.yaml**

- [ ] **🔥 Seções claras** - ESSENCIAL → OPCIONAL → AVANÇADO
- [ ] **💬 Comentários educativos** - Explicam quando/como usar
- [ ] **🎯 Domain primeiro** - Para aplicações web
- [ ] **📦 Image completo** - Repository + tag + pullPolicy
- [ ] **⚙️ Resources simples** - CPU e memory diretos
- [ ] **🔧 advanced.enabled=false** - Complexidade opcional
- [ ] **📊 Defaults funcionais** - Funciona sem configuração

### **📝 Para Comentários**

- [ ] **📋 Headers de seção** - Com emojis e divisórias
- [ ] **💡 Contexto prático** - Quando usar cada configuração
- [ ] **🎯 Exemplos inline** - Valores reais nos comentários
- [ ] **⚠️ Alertas importantes** - Configurações críticas
- [ ] **🔗 Referências** - Links quando necessário

### **🧪 Para Testes**

- [ ] **✅ Helm template** - Gera YAML válido
- [ ] **🚀 Instalação básica** - Domain + password funciona
- [ ] **🔧 Features opcionais** - TLS, auth, persistence testados
- [ ] **⚙️ Advanced** - Configurações complexas funcionam
- [ ] **📋 Combinações** - Múltiplas features juntas

### **📖 Para Documentação**

- [ ] **🎯 README atualizado** - Reflete estrutura do values
- [ ] **📊 Tabela de configurações** - Parâmetros principais
- [ ] **🔧 Exemplos práticos** - Dev, produção, específicos
- [ ] **🚨 Troubleshooting** - Problemas comuns documentados

---

## 🎯 **RESUMO EXECUTIVO**

### **✅ Padrão Testado e Aprovado:**
1. **🚀 ESSENCIAL primeiro** - Domain, image, resources
2. **⚡ OPCIONAL depois** - Features habilitáveis
3. **🔧 AVANÇADO por último** - Complexidade opcional
4. **💬 COMENTÁRIOS educativos** - Explicam o porquê

### **📋 Estrutura que Funciona:**
- **Domain sempre primeiro** (aplicações web)
- **Image sempre presente** (repository + tag + pullPolicy)
- **Resources simples** (cpu + memory diretos)
- **advanced.enabled=false** (padrão)

### **🎯 Objetivo Final:**
**Values.yaml que permitem deployar aplicações em produção com comandos de uma linha, mas oferecem toda flexibilidade quando necessário!**

---

**💡 Baseado nos padrões reais dos charts Bridge, MinIO e Redis - funcionam em produção há meses!** 