# 🔧 Troubleshooting - Guia de Resolução de Problemas

## 🎯 **Objetivo**
Este guia ajuda a **identificar e resolver** os problemas mais comuns ao usar charts Helm simplificados. Focado em **usuários iniciantes** com linguagem clara e comandos práticos.

---

## 🚨 **PROBLEMAS MAIS COMUNS**

### **1. 🚫 Chart não instala (helm install falha)**

#### **Sintomas:**
```bash
helm install meu-app charts/bridge --set domain=app.com
Error: failed to install chart
```

#### **Possíveis Causas & Soluções:**

**🔍 A) Namespace não existe**
```bash
# Verificar se namespace existe
kubectl get namespaces

# Criar namespace se necessário
kubectl create namespace meu-namespace

# Instalar no namespace específico
helm install meu-app charts/bridge \
  --namespace meu-namespace \
  --set domain=app.com
```

**🔍 B) Valores obrigatórios em falta**
```bash
# Erro comum: domain não definido
Error: domain é obrigatório. Use: --set domain=meuapp.com

# Solução:
helm install meu-app charts/bridge \
  --set domain=meuapp.com
```

**🔍 C) Chart.yaml inválido**
```bash
# Validar sintaxe do chart
helm lint charts/meu-chart

# Verificar se arquivos obrigatórios existem
ls charts/meu-chart/
# Deve ter: Chart.yaml, values.yaml, templates/
```

---

### **2. 🔄 Pod fica em status Pending**

#### **Sintomas:**
```bash
kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
meu-app-bridge-xxx       0/1     Pending   0          5m
```

#### **Diagnóstico:**
```bash
# 1. Verificar eventos do pod
kubectl describe pod meu-app-bridge-xxx

# 2. Verificar eventos do namespace
kubectl get events --sort-by=.metadata.creationTimestamp
```

#### **Possíveis Causas & Soluções:**

**🔍 A) Recursos insuficientes**
```bash
# Verificar recursos disponíveis
kubectl top nodes
kubectl describe nodes

# Solução: Reduzir recursos no values.yaml
helm upgrade meu-app charts/bridge \
  --set resources.cpu=50m \
  --set resources.memory=64Mi
```

**🔍 B) PVC não pode ser provisionado**
```bash
# Verificar PVCs
kubectl get pvc

# Verificar storage classes disponíveis
kubectl get storageclass

# Solução: Usar storage class correto
helm upgrade meu-app charts/bridge \
  --set persistence.storageClass=local-path
```

**🔍 C) Node selector ou taints**
```bash
# Verificar nodes e taints
kubectl get nodes --show-labels
kubectl describe nodes

# Solução: Remover node selector se não necessário
```

---

### **3. 🔴 Pod fica em status CrashLoopBackOff**

#### **Sintomas:**
```bash
kubectl get pods
NAME                     READY   STATUS             RESTARTS   AGE
meu-app-bridge-xxx       0/1     CrashLoopBackOff   5          10m
```

#### **Diagnóstico:**
```bash
# 1. Ver logs do container
kubectl logs meu-app-bridge-xxx

# 2. Ver logs anteriores (se reiniciou)
kubectl logs meu-app-bridge-xxx --previous

# 3. Descrever o pod para ver eventos
kubectl describe pod meu-app-bridge-xxx
```

#### **Possíveis Causas & Soluções:**

**🔍 A) Imagem não existe ou inacessível**
```bash
# Erro nos logs:
# Failed to pull image "nginx:versao-inexistente"

# Solução: Usar tag válida
helm upgrade meu-app charts/bridge \
  --set image.tag=1.21
```

**🔍 B) Configuração inválida**
```bash
# Verificar ConfigMaps e Secrets
kubectl get configmap
kubectl get secret

# Ver conteúdo do ConfigMap
kubectl describe configmap meu-app-bridge-config
```

**🔍 C) Health check falhando**
```bash
# Erro nos eventos:
# Liveness probe failed: HTTP probe failed

# Solução: Ajustar ou desabilitar health checks temporariamente
```

---

### **4. 🌐 Aplicação não acessível externamente**

#### **Sintomas:**
- Pods rodando normalmente
- Não consigo acessar via domínio configurado

#### **Diagnóstico:**
```bash
# 1. Verificar se pods estão rodando
kubectl get pods -l app.kubernetes.io/name=bridge

# 2. Verificar services
kubectl get svc -l app.kubernetes.io/name=bridge

# 3. Verificar IngressRoute (Traefik)
kubectl get ingressroute

# 4. Testar conectividade interna
kubectl port-forward svc/meu-app-bridge 8080:80
# Depois testar: curl localhost:8080
```

#### **Possíveis Causas & Soluções:**

**🔍 A) Service não expondo porta correta**
```bash
# Verificar se service aponta para porta certa
kubectl describe svc meu-app-bridge

# Verificar se selector está correto
kubectl get pods --show-labels
```

**🔍 B) IngressRoute não criado**
```bash
# Verificar se domain foi definido
helm get values meu-app

# Se domain estiver vazio:
helm upgrade meu-app charts/bridge \
  --set domain=meuapp.meusite.com
```

**🔍 C) DNS não resolve**
```bash
# Testar resolução DNS
nslookup meuapp.meusite.com

# Para desenvolvimento local, adicionar ao /etc/hosts:
# 127.0.0.1 meuapp.meusite.com
```

---

### **5. 🔐 Problemas de Autenticação**

#### **Sintomas:**
- Erro 401 ou 403 ao acessar aplicação
- "Authentication required"

#### **Diagnóstico:**
```bash
# 1. Verificar se auth está habilitada
helm get values meu-app | grep auth

# 2. Verificar secret de autenticação
kubectl get secret meu-app-bridge-auth

# 3. Ver conteúdo do secret (base64 decoded)
kubectl get secret meu-app-bridge-auth -o jsonpath='{.data.users}' | base64 -d
```

#### **Possíveis Causas & Soluções:**

**🔍 A) Senha não definida**
```bash
# Definir usuário e senha
helm upgrade meu-app charts/bridge \
  --set auth.enabled=true \
  --set auth.username=admin \
  --set auth.password=minhasenha123
```

**🔍 B) Middleware não aplicado**
```bash
# Verificar middlewares
kubectl get middleware

# Verificar se IngressRoute usa o middleware
kubectl describe ingressroute meu-app-bridge
```

---

## 📋 **CHECKLIST DE VERIFICAÇÃO RÁPIDA**

Quando algo não funciona, siga esta sequência:

### **✅ 1. Verificações Básicas**
```bash
# Pods estão rodando?
kubectl get pods

# Services existem?
kubectl get svc

# IngressRoute criado?
kubectl get ingressroute
```

### **✅ 2. Verificar Logs**
```bash
# Logs da aplicação
kubectl logs -l app.kubernetes.io/name=SEU_CHART

# Eventos recentes
kubectl get events --sort-by=.metadata.creationTimestamp | tail -10
```

### **✅ 3. Verificar Configuração**
```bash
# Values utilizados
helm get values RELEASE_NAME

# Manifests gerados
helm get manifest RELEASE_NAME
```

### **✅ 4. Teste de Conectividade**
```bash
# Port-forward para testar
kubectl port-forward svc/SEU_SERVICE 8080:80

# Teste em localhost:8080
curl localhost:8080
```

---

## 🛠️ **COMANDOS DE DEBUG ESSENCIAIS**

### **📊 Visão Geral do Cluster**
```bash
# Status geral dos recursos
kubectl get all

# Recursos por namespace
kubectl get all -n meu-namespace

# Top de recursos (CPU/Memory)
kubectl top nodes
kubectl top pods
```

### **🔍 Investigação Detalhada**
```bash
# Descrever recurso específico
kubectl describe pod NOME_DO_POD
kubectl describe svc NOME_DO_SERVICE
kubectl describe ingressroute NOME_DO_INGRESS

# Ver definição YAML completa
kubectl get pod NOME_DO_POD -o yaml
kubectl get svc NOME_DO_SERVICE -o yaml
```

### **📝 Logs e Eventos**
```bash
# Logs em tempo real
kubectl logs -f NOME_DO_POD

# Logs de todos os containers de um deployment
kubectl logs -l app.kubernetes.io/name=bridge --all-containers

# Eventos ordenados por tempo
kubectl get events --sort-by=.metadata.creationTimestamp

# Eventos de um namespace específico
kubectl get events -n meu-namespace
```

### **🔧 Helm Específicos**
```bash
# Status da release
helm status RELEASE_NAME

# Histórico de releases
helm history RELEASE_NAME

# Fazer rollback se necessário
helm rollback RELEASE_NAME 1

# Validar chart antes de instalar
helm lint PATH_DO_CHART
helm template RELEASE_NAME PATH_DO_CHART --debug
```

---

## 🚨 **ERROS COMUNS E SOLUÇÕES RÁPIDAS**

### **Error: failed to install/upgrade chart**
```bash
# Validar sintaxe
helm lint charts/SEU_CHART

# Testar sem instalar
helm template test charts/SEU_CHART --set domain=test.com
```

### **ImagePullBackOff**
```bash
# Verificar se imagem existe
docker pull IMAGE:TAG

# Usar imagem pública conhecida para teste
helm upgrade RELEASE charts/CHART --set image.repository=nginx --set image.tag=1.21
```

### **0/1 nodes are available**
```bash
# Verificar recursos
kubectl describe nodes

# Reduzir requests de recursos
helm upgrade RELEASE charts/CHART --set resources.cpu=10m --set resources.memory=32Mi
```

### **connection refused**
```bash
# Verificar se aplicação escuta na porta correta
kubectl logs POD_NAME

# Verificar se service aponta para porta correta
kubectl describe svc SERVICE_NAME
```

---

## 📞 **QUANDO PEDIR AJUDA**

Se após seguir este guia o problema persistir, colete as seguintes informações:

### **📋 Informações Necessárias**
```bash
# 1. Versão do Kubernetes
kubectl version --short

# 2. Charts e releases instalados
helm list --all-namespaces

# 3. Status dos recursos
kubectl get all -o wide

# 4. Logs recentes
kubectl logs -l app.kubernetes.io/name=SEU_CHART --tail=50

# 5. Eventos recentes
kubectl get events --sort-by=.metadata.creationTimestamp --all-namespaces | tail -20

# 6. Configuração utilizada
helm get values RELEASE_NAME
```

### **📝 Template para Report de Problema**
```
## Problema
[Descreva o que está acontecendo]

## Comando Executado
```bash
helm install ...
```

## Comportamento Esperado
[O que deveria acontecer]

## Comportamento Atual
[O que realmente acontece]

## Logs
```bash
[Saída dos comandos de debug]
```

## Ambiente
- Kubernetes: [versão]
- Helm: [versão] 
- Chart: [nome e versão]
```

---

## 🎯 **DICAS DE PREVENÇÃO**

### **✅ Antes de Instalar**
- Sempre validar o chart: `helm lint`
- Testar template: `helm template`
- Verificar recursos disponíveis: `kubectl top nodes`

### **✅ Durante o Desenvolvimento**
- Começar com configuração mínima
- Adicionar complexidade gradualmente
- Testar cada mudança incrementalmente

### **✅ Em Produção**
- Sempre testar em ambiente de desenvolvimento primeiro
- Fazer backup antes de upgrades
- Monitorar logs após mudanças

---

**💡 Dica Final:** A maioria dos problemas com charts simplificados são devido a configuração incorreta ou recursos insuficientes. Sempre comece verificando os basics: pods, services e configuração! 