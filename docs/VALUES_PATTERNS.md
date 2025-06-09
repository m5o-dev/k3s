# ⚙️ Values.yaml Patterns - Padrões de Configuração

## 🎯 **FILOSOFIA**

O `values.yaml` é a **interface principal** entre o usuário e o chart. Ele deve ser:

1. **Intuitivo**: Usuário encontra o que precisa rapidamente
2. **Progressivo**: Do simples ao complexo
3. **Autodocumentado**: Comentários explicam tudo
4. **Funcional**: Defaults que funcionam out-of-the-box

## 📋 **ESTRUTURA OBRIGATÓRIA**

### **Template Base**
```yaml
# =============================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# =============================================================================
# Estas são as configurações que 80% dos usuários vão alterar

# Domínio/URL onde a aplicação será acessível (OBRIGATÓRIO)
domain: "exemplo.com"

# Configuração da Imagem Docker
image:
  repository: "nginx"           # Repositório da imagem
  tag: "1.21"                  # Versão/tag da imagem
  pullPolicy: IfNotPresent     # Política de download (IfNotPresent, Always, Never)

# Recursos de CPU e Memória
resources:
  cpu: "100m"                  # CPU: 100m = 0.1 core
  memory: "128Mi"              # Memória: 128Mi = 128 Megabytes

# =============================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# =============================================================================
# Funcionalidades que podem ser habilitadas conforme necessário

# Réplicas da aplicação
replicas: 1                    # Número de pods rodando simultaneamente

# Autenticação Básica HTTP
auth:
  enabled: false               # Habilita autenticação básica
  username: ""                 # Usuário para login
  password: ""                 # Senha para login

# TLS/HTTPS
tls:
  enabled: false               # Habilita HTTPS automático

# Health Checks para monitoramento da aplicação
healthcheck:
  enabled: false               # Habilita health checks
  startup:
    enabled: false             # Para apps que demoram para iniciar
    path: "/health"           # Endpoint de verificação
    initialDelaySeconds: 10   # Aguardar antes do primeiro check
    periodSeconds: 10         # Intervalo entre checks
    failureThreshold: 30      # Tentativas antes de falhar
  liveness:
    enabled: false             # Detecção de apps travadas
    path: "/health"           # Endpoint de verificação
    initialDelaySeconds: 30   # Aguardar app estar rodando
    periodSeconds: 10         # Intervalo entre checks
    failureThreshold: 3       # Tentativas antes de reiniciar
  readiness:
    enabled: false             # Controle de tráfego
    path: "/ready"            # Endpoint de prontidão
    initialDelaySeconds: 5    # Verificar logo após startup
    periodSeconds: 5          # Intervalo entre checks
    failureThreshold: 3       # Tentativas antes de remover do service
  
# Configurações de Rede
networking:
  port: 80                     # Porta interna da aplicação
  serviceType: ClusterIP       # Tipo do serviço (ClusterIP, NodePort, LoadBalancer)

# =============================================================================
# 🔧 CONFIGURAÇÃO AVANÇADA
# =============================================================================
# Configurações para usuários experientes (raramente alteradas)

# Sobrescrever nomes dos recursos
nameOverride: ""               # Sobrescreve o nome do chart
fullnameOverride: ""           # Sobrescreve o nome completo dos recursos

# Componente (usado nas labels)
component: "application"        # Tipo de componente (application, database, cache, etc.)

# Node Selector
nodeSelector: {}               # Selecionar nós específicos

# Tolerations
tolerations: []                # Tolerâncias para nós com taints

# Affinity
affinity: {}                   # Regras de afinidade/anti-afinidade

# Security Context
securityContext: {}            # Contexto de segurança

# Pod Annotations
podAnnotations: {}             # Anotações customizadas para pods

# Service Annotations  
serviceAnnotations: {}         # Anotações customizadas para services

# Configurações extremamente avançadas (OPCIONAL)
# ⚠️  Esta seção só é aplicada se advanced.enabled=true for definido
# Por padrão, esta seção pode ser omitida completamente do values.yaml
advanced:
  enabled: false               # Habilita seção de configurações avançadas
  # ⚠️ Configurações abaixo só são aplicadas se advanced.enabled=true
```

## 🏷️ **PADRÕES POR TIPO DE CHART**

### **Aplicação Web**
```yaml
domain: "app.exemplo.com"
image:
  repository: "nginx"
  tag: "1.21"
  pullPolicy: IfNotPresent
resources:
  cpu: "100m"
  memory: "128Mi"
replicas: 1
auth:
  enabled: false
  username: ""
  password: ""
tls:
  enabled: false
```

### **Banco de Dados**
```yaml
# Não usa domain, mas sim configurações específicas
image:
  repository: "postgres"
  tag: "13"
  pullPolicy: IfNotPresent
resources:
  cpu: "200m"
  memory: "256Mi"
database:
  name: "myapp"
  username: "user"
  password: ""  # DEVE ser preenchido
persistence:
  enabled: true
  size: "10Gi"
  storageClass: ""
```

### **Cache/Message Queue**
```yaml
image:
  repository: "redis"
  tag: "6.2"
  pullPolicy: IfNotPresent
resources:
  cpu: "100m"
  memory: "128Mi"
persistence:
  enabled: false
  size: "5Gi"
config:
  maxMemory: "100mb"
  evictionPolicy: "allkeys-lru"
```

## 📝 **CONVENÇÕES DE NOMENCLATURA**

### **Seções Principais**
- `domain` - URL/domínio (sempre no topo para apps web)
- `image` - Configuração da imagem Docker
- `resources` - CPU e memória  
- `replicas` - Número de instâncias
- `auth` - Autenticação
- `tls` - Configurações HTTPS/TLS
- `persistence` - Armazenamento persistente
- `networking` - Configurações de rede
- `config` - Configurações específicas da aplicação

### **Convenções de Valores**
- **Booleanos**: `enabled`, `disabled` (preferir `enabled`)
- **Strings**: aspas duplas para valores padrão
- **Números**: sem aspas para números, com aspas para versões
- **Listas/Maps**: vazios `{}` ou `[]` como padrão

## 💡 **MELHORES PRÁTICAS**

### **1. Comentários Educativos**
```yaml
# ❌ Ruim
cpu: "100m"

# ✅ Bom  
cpu: "100m"                  # CPU: 100m = 0.1 core, 1000m = 1 core

# ✅ Ainda melhor
resources:
  cpu: "100m"                # CPU: 100m = 0.1 core, 1000m = 1 core
  memory: "128Mi"            # Memória: 128Mi = 128 Megabytes, 1Gi = 1024Mi
```

### **2. Valores Sensatos**
```yaml
# ✅ Defaults que funcionam
image:
  repository: "nginx"        # Imagem conhecida e estável
  tag: "1.21"               # Versão específica (não latest)
  pullPolicy: IfNotPresent  # Política eficiente

resources:
  cpu: "100m"               # Suficiente para apps simples
  memory: "128Mi"           # Memória básica adequada
```

### **3. Organização Visual**
```yaml
# =============================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# =============================================================================

domain: "app.exemplo.com"

# Configuração da Imagem Docker
image:
  repository: "nginx"
  tag: "1.21"
  pullPolicy: IfNotPresent

# =============================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS  
# =============================================================================

auth:
  enabled: false
  username: ""
  password: ""
```

### **4. Validação via Templates**
```yaml
# No template, validar valores obrigatórios
{{- if not .Values.domain }}
{{- fail "domain é obrigatório. Use: --set domain=meuapp.com" }}
{{- end }}

{{- if and .Values.auth.enabled (not .Values.auth.password) }}
{{- fail "auth.password é obrigatório quando auth.enabled=true" }}
{{- end }}
```

## 🔍 **EXEMPLOS POR CASO DE USO**

### **Para Tutoriais Básicos**
```yaml
domain: "meuapp.localhost"
image:
  repository: "nginx"
  tag: "1.21"
resources:
  cpu: "50m"
  memory: "64Mi"
```

### **Para Desenvolvimento**
```yaml
domain: "app.dev.empresa.com"
image:
  repository: "meuapp"
  tag: "dev"
resources:
  cpu: "100m"
  memory: "128Mi"
replicas: 1
```

### **Para Produção**
```yaml
domain: "app.empresa.com"
image:
  repository: "meuapp"
  tag: "v1.2.3"
resources:
  cpu: "500m"
  memory: "512Mi"
replicas: 3
auth:
  enabled: true
  username: "admin"
  password: "senha-segura"
tls:
  enabled: true
```

## ⚠️ **COISAS A EVITAR**

### **❌ Não fazer**
```yaml
# Muito técnico para iniciantes
spec:
  template:
    spec:
      containers:
      - resources:
          limits:
            cpu: 100m

# Nomes não intuitivos  
ingress:
  className: traefik
  annotations:
    traefik.ingress.kubernetes.io/router.rule: Host(`app.com`)

# Defaults que não funcionam
domain: ""                   # Usuário não sabe que precisa preencher
image:
  tag: "latest"             # Pode quebrar com atualizações
```

### **✅ Fazer**
```yaml
# Simples e claro
resources:
  cpu: "100m"               # CPU: 100m = 0.1 core
  memory: "128Mi"           # Memória: 128Mi = 128 Megabytes

# Nomes intuitivos
domain: "app.exemplo.com"   # URL onde a aplicação será acessível

# Defaults funcionais
image:
  tag: "1.21"               # Versão específica e testada
```

## 📊 **CHECKLIST VALUES.YAML**

- [ ] **Seções organizadas**: Essencial → Opcional → Avançado
- [ ] **Comentários educativos**: Explicam o que cada valor faz
- [ ] **Defaults funcionais**: Chart funciona sem alterações
- [ ] **Valores intuitivos**: Nomes fazem sentido para iniciantes
- [ ] **Validação**: Templates verificam valores obrigatórios
- [ ] **Consistência**: Segue padrões do projeto
- [ ] **Progressivo**: Usuário pode começar simples e evoluir

---

**Use este guia** sempre que criar ou modificar um `values.yaml`! 