# 🏥 Health Checks - Guia de Verificações de Saúde

## 🎯 **Objetivo**
Este guia explica como implementar **health checks** nos templates de Deployment para garantir que aplicações funcionem corretamente e sejam confiáveis no Kubernetes.

---

## 🔍 **TIPOS DE HEALTH CHECKS**

### **1. 🚀 Startup Probe**
**Quando usar:** Aplicações que **demoram para inicializar** (ex: Java, Spring Boot, bancos de dados)

**Função:** Verifica se a aplicação terminou de inicializar antes de ativar outros probes

```yaml
startupProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 10    # Aguarda 10s antes do primeiro check
  periodSeconds: 10         # Verifica a cada 10s
  timeoutSeconds: 5         # Timeout de 5s por verificação
  failureThreshold: 30      # Falha após 30 tentativas (5min total)
```

---

### **2. ❤️ Liveness Probe**
**Quando usar:** **Sempre** que possível, para detectar aplicações "travadas"

**Função:** Kubernetes **reinicia o container** se este check falhar

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30   # Aguarda app estar rodando
  periodSeconds: 10        # Verifica a cada 10s
  timeoutSeconds: 5        # Timeout de 5s
  failureThreshold: 3      # Reinicia após 3 falhas consecutivas
```

---

### **3. 🟢 Readiness Probe**
**Quando usar:** **Sempre**, para controlar tráfego de entrada

**Função:** Kubernetes **remove pod do Service** se este check falhar

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5    # Verifica logo após startup
  periodSeconds: 5         # Verifica a cada 5s
  timeoutSeconds: 3        # Timeout mais baixo
  failureThreshold: 3      # Remove do service após 3 falhas
```

---

## 📋 **MÉTODOS DE VERIFICAÇÃO**

### **🌐 HTTP Check (Mais Comum)**
```yaml
httpGet:
  path: /health          # Endpoint de saúde da aplicação
  port: http            # Porta do container (ou número)
  httpHeaders:          # Headers opcionais
  - name: Host
    value: myapp.com
```

**Códigos de resposta:**
- `200-399`: ✅ Sucesso
- `400+`: ❌ Falha

---

### **🔌 TCP Check**
```yaml
tcpSocket:
  port: http            # Verifica se porta está aceitando conexões
```

**Quando usar:** Aplicações sem endpoint HTTP (ex: bancos de dados, Redis)

---

### **⚡ Command Check**
```yaml
exec:
  command:
  - cat
  - /tmp/healthy       # Verifica se arquivo existe
```

**Quando usar:** Verificações customizadas específicas

---

## 🛠️ **IMPLEMENTAÇÃO NO TEMPLATE**

### **Template Básico com Health Checks**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
spec:
  template:
    spec:
      containers:
      - name: "{{ .Chart.Name }}"
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - name: http
          containerPort: {{ .Values.port | default 80 }}
        
        # Health Checks Opcionais
        {{- if .Values.healthcheck.enabled }}
        {{- if .Values.healthcheck.startup.enabled }}
        startupProbe:
          httpGet:
            path: {{ .Values.healthcheck.startup.path | default "/health" }}
            port: http
          initialDelaySeconds: {{ .Values.healthcheck.startup.initialDelaySeconds | default 10 }}
          periodSeconds: {{ .Values.healthcheck.startup.periodSeconds | default 10 }}
          failureThreshold: {{ .Values.healthcheck.startup.failureThreshold | default 30 }}
        {{- end }}
        
        {{- if .Values.healthcheck.liveness.enabled }}
        livenessProbe:
          httpGet:
            path: {{ .Values.healthcheck.liveness.path | default "/health" }}
            port: http
          initialDelaySeconds: {{ .Values.healthcheck.liveness.initialDelaySeconds | default 30 }}
          periodSeconds: {{ .Values.healthcheck.liveness.periodSeconds | default 10 }}
          failureThreshold: {{ .Values.healthcheck.liveness.failureThreshold | default 3 }}
        {{- end }}
        
        {{- if .Values.healthcheck.readiness.enabled }}
        readinessProbe:
          httpGet:
            path: {{ .Values.healthcheck.readiness.path | default "/ready" }}
            port: http
          initialDelaySeconds: {{ .Values.healthcheck.readiness.initialDelaySeconds | default 5 }}
          periodSeconds: {{ .Values.healthcheck.readiness.periodSeconds | default 5 }}
          failureThreshold: {{ .Values.healthcheck.readiness.failureThreshold | default 3 }}
        {{- end }}
        {{- end }}
```

---

## ⚙️ **CONFIGURAÇÃO NO VALUES.YAML**

### **Estrutura Recomendada**
```yaml
# =============================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# =============================================================================

# Health Checks para monitoramento da aplicação
healthcheck:
  enabled: false                    # Habilita health checks
  
  startup:
    enabled: false                  # Para apps que demoram para iniciar
    path: "/health"                # Endpoint de verificação
    initialDelaySeconds: 10        # Aguardar antes do primeiro check
    periodSeconds: 10             # Intervalo entre checks
    failureThreshold: 30          # Tentativas antes de falhar
    
  liveness:
    enabled: false                  # Detecção de apps travadas
    path: "/health"                # Endpoint de verificação
    initialDelaySeconds: 30        # Aguardar app estar rodando
    periodSeconds: 10             # Intervalo entre checks
    failureThreshold: 3           # Tentativas antes de reiniciar
    
  readiness:
    enabled: false                  # Controle de tráfego
    path: "/ready"                 # Endpoint de prontidão
    initialDelaySeconds: 5         # Verificar logo após startup
    periodSeconds: 5              # Intervalo entre checks
    failureThreshold: 3           # Tentativas antes de remover do service
```

---

## 💡 **MELHORES PRÁTICAS**

### **✅ Configuração Recomendada por Tipo de App**

#### **🌐 Aplicação Web (nginx, Apache)**
```yaml
healthcheck:
  enabled: true
  liveness:
    enabled: true
    path: "/"                     # Página principal ou /health
    initialDelaySeconds: 15
    periodSeconds: 10
    failureThreshold: 3
  readiness:
    enabled: true
    path: "/"
    initialDelaySeconds: 5
    periodSeconds: 5
    failureThreshold: 2
```

#### **☕ Aplicação Java/Spring Boot**
```yaml
healthcheck:
  enabled: true
  startup:
    enabled: true                 # Java demora para iniciar
    path: "/actuator/health"
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 60          # Até 10 minutos para iniciar
  liveness:
    enabled: true
    path: "/actuator/health"
    initialDelaySeconds: 60
    periodSeconds: 30
    failureThreshold: 3
  readiness:
    enabled: true
    path: "/actuator/health"
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 3
```

#### **🐍 API Python/Node.js**
```yaml
healthcheck:
  enabled: true
  liveness:
    enabled: true
    path: "/health"
    initialDelaySeconds: 10
    periodSeconds: 10
    failureThreshold: 3
  readiness:
    enabled: true
    path: "/ready"
    initialDelaySeconds: 5
    periodSeconds: 5
    failureThreshold: 2
```

#### **🗄️ Banco de Dados (TCP Check)**
```yaml
healthcheck:
  enabled: true
  liveness:
    enabled: true
    type: "tcp"                   # Não usa HTTP
    port: 5432                   # Porta do banco
    initialDelaySeconds: 30
    periodSeconds: 20
    failureThreshold: 3
  readiness:
    enabled: true
    type: "tcp"
    port: 5432
    initialDelaySeconds: 10
    periodSeconds: 10
    failureThreshold: 3
```

---

## 🚨 **PROBLEMAS COMUNS E SOLUÇÕES**

### **1. Pod fica reiniciando (CrashLoopBackOff)**

**Causa:** Liveness probe falhando

**Solução:**
```bash
# Ver logs do container
kubectl logs pod-name --previous

# Verificar se endpoint /health existe
kubectl port-forward pod-name 8080:80
curl localhost:8080/health

# Temporariamente desabilitar liveness
helm upgrade app chart --set healthcheck.liveness.enabled=false
```

---

### **2. Pod não recebe tráfego**

**Causa:** Readiness probe falhando

**Solução:**
```bash
# Verificar status dos endpoints
kubectl get endpoints

# Testar endpoint de readiness
curl localhost:8080/ready

# Verificar se paths estão corretos
helm get values release-name | grep healthcheck
```

---

### **3. App demora muito para ficar "Ready"**

**Causa:** Configuração inadequada para startup

**Solução:**
```yaml
# Aumentar tempo de startup
healthcheck:
  startup:
    enabled: true
    failureThreshold: 60      # Até 10 minutos
  readiness:
    initialDelaySeconds: 30   # Aguardar mais tempo
```

---

## 🔧 **IMPLEMENTAÇÃO STEP-BY-STEP**

### **Passo 1: Criar Endpoint na Aplicação**
```bash
# Exemplo simples em nginx
echo '{"status": "ok"}' > /usr/share/nginx/html/health

# Para apps customizadas, implementar:
# GET /health -> 200 se app OK
# GET /ready -> 200 se app pronta para tráfego
```

### **Passo 2: Adicionar ao Values.yaml**
```yaml
healthcheck:
  enabled: true
  liveness:
    enabled: true
    path: "/health"
  readiness:
    enabled: true
    path: "/health"
```

### **Passo 3: Testar Configuração**
```bash
# Validar template
helm template test chart --set healthcheck.enabled=true

# Instalar e monitorar
helm install app chart --set healthcheck.enabled=true
kubectl get pods -w
```

### **Passo 4: Validar Funcionamento**
```bash
# Verificar se probes estão configurados
kubectl describe pod pod-name

# Verificar eventos
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## 📊 **TROUBLESHOOTING HEALTH CHECKS**

### **Comandos de Debug**
```bash
# Status detalhado do pod
kubectl describe pod POD_NAME

# Logs da aplicação
kubectl logs POD_NAME

# Testar endpoint manualmente
kubectl port-forward POD_NAME 8080:80
curl -v localhost:8080/health

# Ver configuração dos probes
kubectl get pod POD_NAME -o yaml | grep -A 10 "livenessProbe\|readinessProbe"
```

### **Métricas para Monitorar**
- **Restart count**: Indica problemas com liveness
- **Ready status**: Indica problemas com readiness  
- **Events**: Mostra falhas de probe
- **Response time**: Endpoint deve responder < timeout

---

## 🎯 **CONFIGURAÇÃO PARA PRODUÇÃO**

### **Valores Conservadores (Recomendado)**
```yaml
healthcheck:
  enabled: true
  liveness:
    enabled: true
    initialDelaySeconds: 60      # Aguardar bem mais
    periodSeconds: 30           # Verificar menos frequente
    timeoutSeconds: 10          # Timeout maior
    failureThreshold: 5         # Mais tolerante
  readiness:
    enabled: true
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
```

### **Valores Agressivos (Desenvolvimento)**
```yaml
healthcheck:
  enabled: true
  liveness:
    enabled: true
    initialDelaySeconds: 10      # Rápido para debug
    periodSeconds: 5            # Verifica frequente
    failureThreshold: 2         # Falha rápido
  readiness:
    enabled: true
    initialDelaySeconds: 2
    periodSeconds: 3
    failureThreshold: 2
```

---

**💡 Dica Final:** Comece sempre com health checks **desabilitados**, teste a aplicação, depois habilite gradualmente: readiness → liveness → startup. Isso evita problemas durante o desenvolvimento! 