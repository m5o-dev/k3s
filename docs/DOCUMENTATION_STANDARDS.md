# 📚 **PADRÕES DE DOCUMENTAÇÃO**

> **Diretrizes obrigatórias** para documentação clara, consistente e educativa

---

## 📋 **ÍNDICE**

1. [🎯 Filosofia de Documentação](#-filosofia-de-documentação)
2. [📖 Padrões de README](#-padrões-de-readme)
3. [💬 Comentários Educativos](#-comentários-educativos)
4. [📝 Documentação Inline](#-documentação-inline)
5. [🎓 Linguagem e Tom](#-linguagem-e-tom)
6. [📋 Templates de Comunicação](#-templates-de-comunicação)
7. [🔧 Exemplos Práticos](#-exemplos-práticos)
8. [✅ Checklist de Qualidade](#-checklist-de-qualidade)

---

## 🎯 **Filosofia de Documentação**

### **💡 Princípios Fundamentais**

#### **1. 🎓 Educação em Primeiro Lugar**
- **Ensinar, não apenas instruir** - Explicar o "porquê", não só o "como"
- **Progressivo** - Do básico ao avançado
- **Contextual** - Sempre explicar quando e por que usar
- **Prático** - Exemplos funcionais em vez de teoria abstrata

#### **2. 🌟 Clareza e Simplicidade**
- **Linguagem simples** - Evitar jargões desnecessários
- **Estrutura consistente** - Padrões em todos os documentos
- **Navegação intuitiva** - Fácil de encontrar informação
- **Visual friendly** - Emojis, tabelas, destaques

#### **3. 🚀 Foco na Experiência do Usuário**
- **Cenários reais** - Exemplos baseados em casos de uso
- **Copy-paste ready** - Comandos que funcionam imediatamente
- **Troubleshooting proativo** - Antecipar problemas comuns
- **Feedback loops** - Validação se funcionou

#### **4. 🔄 Manutenibilidade**
- **DRY (Don't Repeat Yourself)** - Referenciar em vez de duplicar
- **Versionamento** - Documentação acompanha código
- **Atualização contínua** - Review regular da documentação
- **Modular** - Mudanças localizadas

---

## 📖 **Padrões de README**

### **📋 Estrutura Obrigatória para READMEs de Charts**

#### **Template Padrão:**

```markdown
# 📦 **[NOME DO CHART]**

> **Descrição clara em uma linha** do que o chart faz

---

## 🚀 **Início Rápido**

```bash
# Comando mais simples possível
helm install meu-app new-charts/[nome] \
  --set domain=meuapp.com
```

🎯 **Pronto!** Acesse `http://meuapp.com` e sua aplicação estará funcionando.

---

## 📋 **Pré-requisitos**

- ✅ **Helm 3.x** instalado
- ✅ **Cluster Kubernetes** funcionando  
- ✅ **Domínio configurado** (opcional para testes)
- ✅ **Traefik** como ingress controller

---

## ⚙️ **Configuração**

### **🔧 Configurações Essenciais**

| Parâmetro | Descrição | Valor Padrão | Exemplo |
|-----------|-----------|--------------|---------|
| `domain` | Domínio de acesso | `"app.exemplo.com"` | `"meuapp.com"` |
| `image.repository` | Imagem Docker | `"nginx"` | `"meuapp"` |
| `image.tag` | Tag da imagem | `"1.21"` | `"latest"` |

### **⚡ Funcionalidades Opcionais**

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `auth.enabled` | Habilitar autenticação | `false` |
| `tls.enabled` | Habilitar HTTPS automático | `false` |
| `persistence.enabled` | Armazenamento persistente | `false` |

---

## 🎯 **Exemplos de Uso**

### **Básico (Desenvolvimento)**
```bash
helm install dev new-charts/[nome] \
  --set domain=app.local
```

### **Produção (com TLS e Auth)**
```bash
helm install prod new-charts/[nome] \
  --set domain=app.empresa.com \
  --set tls.enabled=true \
  --set auth.enabled=true \
  --set auth.username=admin \
  --set auth.password=secret123
```

### **Com Values File**
```bash
# Criar values-prod.yaml
cat > values-prod.yaml << EOF
domain: "app.empresa.com"
tls:
  enabled: true
auth:
  enabled: true
  username: "admin"
  password: "secret123"
persistence:
  enabled: true
  size: "10Gi"
EOF

# Instalar
helm install prod new-charts/[nome] -f values-prod.yaml
```

---

## 🔧 **Personalização**

Ver documentação completa de configuração:
- **[VALUES_PATTERNS.md](../docs/VALUES_PATTERNS.md)** - Todos os parâmetros disponíveis
- **[NAMING_STANDARDS.md](../docs/NAMING_STANDARDS.md)** - Estrutura do values.yaml

---

## 🧪 **Testes**

```bash
# Validar configuração
helm template test new-charts/[nome] --set domain=test.com

# Testar instalação
helm install test new-charts/[nome] --set domain=test.com

# Executar testes funcionais
helm test test
```

---

## 🚨 **Troubleshooting**

### **Problemas Comuns**

#### **❌ Chart não instala**
```bash
# Verificar sintaxe
helm lint new-charts/[nome]

# Ver detalhes do erro
kubectl describe pods -l app.kubernetes.io/name=[nome]
```

#### **❌ Aplicação não acessível**
```bash
# Verificar service
kubectl get svc -l app.kubernetes.io/name=[nome]

# Verificar ingressroute
kubectl get ingressroute -l app.kubernetes.io/name=[nome]
```

**📚 Guia completo:** [TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)

---

## 📚 **Documentação**

- **[Chart Guidelines](../docs/CHART_GUIDELINES.md)** - Padrões e filosofia
- **[Testing Strategy](../docs/TESTING_STRATEGY.md)** - Como testar charts
- **[Health Checks](../docs/HEALTH_CHECKS.md)** - Implementar health checks

---

## 🤝 **Contribuindo**

1. Siga os [padrões estabelecidos](../docs/CHART_GUIDELINES.md)
2. Teste com [scripts automatizados](../scripts/test-chart/)
3. Documente mudanças no README

---

## 📄 **Licença**

Este chart segue a licença do projeto principal.
```

### **🎯 Regras para READMEs:**

1. **📏 Tamanho**: Máximo 200 linhas - se maior, dividir em seções
2. **🚀 Início rápido**: Sempre no topo - comando que funciona
3. **📋 Tabelas**: Para parâmetros - mais fácil de ler
4. **🎯 Exemplos**: Pelo menos 3 cenários (dev, staging, prod)
5. **🔗 Referências**: Links para documentação detalhada
6. **📱 Responsivo**: Funciona bem no GitHub/GitLab

---

## 💬 **Comentários Educativos**

### **📋 Padrões para Comentários Inline**

#### **🎯 Values.yaml - Estrutura Obrigatória:**

```yaml
# =================================================================
# 🚀 CONFIGURAÇÃO ESSENCIAL
# Configurações básicas necessárias para funcionamento
# =================================================================

# Domínio onde a aplicação será acessível
# Exemplo: app.meusite.com, api.empresa.com
# ⚠️ OBRIGATÓRIO: Sem domínio a aplicação não será acessível
domain: "app.exemplo.com"

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

# =================================================================
# ⚡ FUNCIONALIDADES OPCIONAIS
# Features que podem ser habilitadas/desabilitadas
# =================================================================

# Autenticação básica HTTP
# enabled: Habilita proteção por usuário/senha
# username/password: Credenciais de acesso
# 🔒 SEGURANÇA: Use secrets em produção
auth:
  enabled: false      # Desabilitado por padrão
  username: ""        # Usuário para acesso
  password: ""        # Senha para acesso

# HTTPS automático com Let's Encrypt
# enabled: Habilita certificados SSL automáticos
# 🌐 PRODUÇÃO: Sempre habilitar em produção
tls:
  enabled: false      # HTTP apenas (desenvolvimento)

# Armazenamento persistente
# enabled: Habilita disco permanente
# size: Tamanho do disco
# storageClass: Tipo de armazenamento
# 💾 DADOS: Habilitar se aplicação salva arquivos
persistence:
  enabled: false      # Sem persistência (stateless)
  size: "1Gi"        # 1GB padrão
  storageClass: ""    # Usar padrão do cluster
```

#### **🎯 Templates - Comentários Educativos:**

```yaml
# =================================================================
# DEPLOYMENT - APLICAÇÃO PRINCIPAL
# =================================================================
# Este template cria o Deployment que executa a aplicação
# Deployment gerencia ReplicaSets que gerenciam Pods
apiVersion: apps/v1
kind: Deployment
metadata:
  # Nome seguindo padrão: {{ .Release.Name }}-{{ .Chart.Name }}
  # Permite múltiplas instalações no mesmo namespace
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  namespace: "{{ .Release.Namespace }}"
  
  # Labels obrigatórias para identificação e seleção
  # Ver NAMING_STANDARDS.md para detalhes completos
  labels:
    app.kubernetes.io/name: "{{ .Chart.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
    app.kubernetes.io/part-of: "{{ .Chart.Name }}"
    app.kubernetes.io/managed-by: "{{ .Release.Service }}"
spec:
  # Número de réplicas (pods) da aplicação
  # Padrão: 1 (para desenvolvimento)
  # Produção: Usar 2+ para alta disponibilidade
  replicas: {{ .Values.replicas | default 1 }}
  
  # Seletor para identificar pods gerenciados
  # IMPORTANTE: Usar apenas name + instance (não version)
  selector:
    matchLabels:
      app.kubernetes.io/name: "{{ .Chart.Name }}"
      app.kubernetes.io/instance: "{{ .Release.Name }}"
  
  # Template para criação dos pods
  template:
    metadata:
      # Labels nos pods DEVEM ser iguais ao metadata do Deployment
      labels:
        app.kubernetes.io/name: "{{ .Chart.Name }}"
        app.kubernetes.io/instance: "{{ .Release.Name }}"
        app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
        app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}
        app.kubernetes.io/part-of: "{{ .Chart.Name }}"
        app.kubernetes.io/managed-by: "{{ .Release.Service }}"
    spec:
      containers:
      - name: "{{ .Chart.Name }}"
        # Imagem Docker da aplicação
        # Formato: repository:tag
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" | quote }}
        
        # Porta onde aplicação escuta dentro do container
        # Nome 'http' é convenção para aplicações web
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        
        # Recursos computacionais (CPU/Memory)
        # Opcional mas recomendado para produção
        {{- with .Values.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
```

### **🎯 Regras para Comentários:**

1. **📝 Explicar o porquê** - Não apenas o que faz
2. **🎓 Contexto educativo** - Quando usar cada configuração
3. **⚠️ Alertas importantes** - Segurança, produção, etc.
4. **📋 Seções organizadas** - Agrupar logicamente
5. **🔗 Referências** - Links para documentação detalhada

---

## 📝 **Documentação Inline**

### **📋 Padrões para Examples**

#### **Template de Cabeçalho:**

```yaml
# =================================================================
# EXEMPLO: [NOME DO RECURSO]
# =================================================================
# 
# PROPÓSITO:
#   Este template demonstra como criar um [recurso] básico
#   para aplicações web simples.
#
# QUANDO USAR:
#   - Aplicações que precisam de [funcionalidade]
#   - Cenários onde [condição específica]
#   - Produção com [requisitos]
#
# PERSONALIZAÇÕES COMUNS:
#   - Mudar `containerPort` se aplicação usa porta diferente
#   - Ajustar `resources` conforme necessidade
#   - Adicionar `env` para variáveis de ambiente
#
# REFERÊNCIAS:
#   - CHART_GUIDELINES.md - Padrões gerais
#   - NAMING_STANDARDS.md - Labels obrigatórias
#   - Kubernetes Docs: https://kubernetes.io/docs/concepts/[recurso]
#
# =================================================================

apiVersion: v1
kind: [Recurso]
# ... resto do template
```

#### **Comentários Inline em Examples:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  # Nome único para este deployment
  # Padrão: release-chart para permitir múltiplas instalações
  name: "{{ .Release.Name }}-{{ .Chart.Name }}"
  
  # Namespace onde será criado
  # Importante: sempre especificar para evitar conflitos
  namespace: "{{ .Release.Namespace }}"
  
  labels:
    # === LABELS OBRIGATÓRIAS ===
    # Estas 6 labels DEVEM estar em TODOS os recursos
    # Ver NAMING_STANDARDS.md para explicação completa
    
    app.kubernetes.io/name: "{{ .Chart.Name }}"           # Nome da aplicação
    app.kubernetes.io/instance: "{{ .Release.Name }}"     # Instância única
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}    # Versão da app
    app.kubernetes.io/component: {{ .Values.component | default "application" | quote }}  # Tipo de componente
    app.kubernetes.io/part-of: "{{ .Chart.Name }}"        # Sistema maior
    app.kubernetes.io/managed-by: "{{ .Release.Service }}" # Gerenciado pelo Helm
spec:
  # Quantas cópias da aplicação executar
  # Desenvolvimento: 1 é suficiente
  # Produção: 2+ para alta disponibilidade
  replicas: {{ .Values.replicas | default 1 }}
  
  selector:
    matchLabels:
      # IMPORTANTE: Use apenas name + instance no selector
      # Não use version ou component aqui - causaria problemas em upgrades
      app.kubernetes.io/name: "{{ .Chart.Name }}"
      app.kubernetes.io/instance: "{{ .Release.Name }}"
```

---

## 🎓 **Linguagem e Tom**

### **📋 Diretrizes de Escrita**

#### **1. 🇧🇷 Idioma**
- **Documentação técnica**: Português brasileiro
- **Código e comentários**: Português nos comentários, inglês nas chaves
- **Comandos**: Inglês (padrão das ferramentas)
- **Mensagens de erro**: Português quando possível

#### **2. 📝 Tom e Estilo**
- **Educativo e amigável** - Como um mentor experiente
- **Direto mas gentil** - Sem condescendência
- **Positivo e encorajador** - "Você consegue!" em vez de "Não faça isso"
- **Inclusivo** - Evitar assumptions sobre conhecimento prévio

#### **3. 📚 Estrutura de Frases**
- **Frases curtas** - Máximo 20 palavras
- **Voz ativa** - "Configure o domain" em vez de "O domain deve ser configurado"
- **Instruções claras** - Verbos no imperativo
- **Contexto primeiro** - Explicar o porquê antes do como

#### **4. 🎯 Vocabulário**

**✅ USAR:**
- **"Configurar"** em vez de "Setar"
- **"Habilitar/Desabilitar"** em vez de "Ativar/Desativar"
- **"Aplicação"** em vez de "App"
- **"Parâmetro"** em vez de "Parameter"
- **"Exemplo"** em vez de "Example"

**❌ EVITAR:**
- Jargões sem explicação
- Anglicismos desnecessários
- Termos muito técnicos sem contexto
- Assumptions sobre conhecimento

### **📋 Exemplos de Tom:**

#### **❌ Tom Ruim:**
```
Obviamente você precisa configurar o domain antes de deployar. 
É básico que você tenha o Helm instalado.
```

#### **✅ Tom Bom:**
```
🎯 Primeiro, vamos configurar o domínio onde sua aplicação será acessível.
Este é o endereço que seus usuários digitarão no navegador.

📋 Pré-requisito: Certifique-se que o Helm está instalado. 
Se não tiver, siga o guia de instalação em [link].
```

---

## 📋 **Templates de Comunicação**

### **🎯 Template de Seção**

```markdown
## 🎯 **[TÍTULO DA SEÇÃO]**

> **Resumo em uma linha** do que esta seção aborda

### **📋 O que você vai aprender:**
- ✅ Primeira coisa importante
- ✅ Segunda coisa importante  
- ✅ Terceira coisa importante

### **⚙️ Implementação:**

[Conteúdo principal com exemplos]

### **💡 Dicas importantes:**
- 🎯 **Dica 1**: Explicação prática
- ⚠️ **Atenção**: Cuidado com este ponto
- 🚀 **Pro tip**: Dica avançada

### **🔗 Referências:**
- [Link para doc relacionada](./outro-doc.md)
- [Link externo](https://exemplo.com)
```

### **📝 Template de Código**

```markdown
### **🔧 [Nome da Configuração]**

**O que faz:**
[Explicação clara em uma frase]

**Quando usar:**
[Cenários específicos]

**Exemplo prático:**
```yaml
# Comentário explicativo
configuracao:
  opcao1: "valor1"    # O que é valor1
  opcao2: "valor2"    # O que é valor2
```

**Resultado esperado:**
[O que acontece após aplicar]

**Troubleshooting:**
- ❌ **Problema comum**: Solução rápida
```

### **🚨 Template de Troubleshooting**

```markdown
#### **❌ [Problema]**
```
Mensagem de erro exata
```

**Causa comum:**
[Explicação do que normalmente causa isso]

**Solução:**
```bash
# Passo 1: Verificar situação atual
comando-de-verificacao

# Passo 2: Aplicar correção
comando-de-correcao

# Passo 3: Validar se funcionou
comando-de-validacao
```

**Como prevenir:**
[Dicas para evitar o problema]
```

---

## 🔧 **Exemplos Práticos**

### **📋 README Exemplar**

Ver exemplo completo na seção de [Padrões de README](#-padrões-de-readme).

### **💬 Comentários Exemplares**

Ver exemplos completos na seção de [Comentários Educativos](#-comentários-educativos).

### **📝 Documentação de API**

```markdown
## 🔧 **Configuração: auth.enabled**

**Tipo:** `boolean`  
**Padrão:** `false`  
**Obrigatório:** Não

**Descrição:**
Habilita autenticação básica HTTP para proteger a aplicação.
Quando habilitado, usuários precisarão fornecer username/password para acessar.

**Dependências:**
- Requer `auth.username` e `auth.password` configurados
- Cria automaticamente um Secret com as credenciais
- Adiciona Middleware do Traefik para autenticação

**Exemplo:**
```yaml
auth:
  enabled: true
  username: "admin"
  password: "secret123"
```

**Segurança:**
🔒 **Importante**: Em produção, use secrets externos em vez de values.yaml

**Relacionado:**
- [Middleware de autenticação](./examples/middleware.yaml)
- [Configuração de secrets](./examples/secret.yaml)
```

---

## ✅ **Checklist de Qualidade**

### **📋 Para READMEs de Charts**

- [ ] **Início rápido**: Comando que funciona em < 30 segundos
- [ ] **Estrutura padrão**: Seguindo template obrigatório
- [ ] **Exemplos práticos**: Pelo menos 3 cenários (dev/staging/prod)
- [ ] **Tabela de parâmetros**: Configurações essenciais documentadas
- [ ] **Troubleshooting**: Problemas mais comuns cobertos
- [ ] **Links de referência**: Para documentação detalhada
- [ ] **Tamanho adequado**: Máximo 200 linhas
- [ ] **Linguagem clara**: Tom educativo e amigável

### **📝 Para Comentários no Código**

- [ ] **Seções organizadas**: Headers com emojis e divisórias
- [ ] **Contexto educativo**: Explicar quando e por que usar
- [ ] **Exemplos inline**: Valores práticos nos comentários
- [ ] **Alertas importantes**: Segurança, produção, etc.
- [ ] **Referências**: Links para docs quando apropriado
- [ ] **Português correto**: Grammar e ortografia
- [ ] **Consistência**: Mesmo padrão em todo arquivo

### **📚 Para Documentação Geral**

- [ ] **Índice navegável**: Links funcionais para seções
- [ ] **Estrutura lógica**: Fluxo natural de aprendizado
- [ ] **Exemplos testados**: Códigos funcionam realmente
- [ ] **Atualização regular**: Sincronizado com código
- [ ] **Feedback incorporado**: Melhorias baseadas em uso
- [ ] **Acessibilidade**: Funciona em diferentes plataformas
- [ ] **Modularidade**: Referências em vez de duplicação

### **🎯 Para Experiência do Usuário**

- [ ] **Jornada clara**: Do básico ao avançado
- [ ] **Copy-paste friendly**: Comandos prontos para usar
- [ ] **Troubleshooting proativo**: Antecipa problemas
- [ ] **Múltiplos formatos**: README + docs + examples
- [ ] **Feedback loops**: Como validar se funcionou
- [ ] **Escalabilidade**: Crescer sem quebrar experiência

---

## 🎯 **RESUMO EXECUTIVO**

### **✅ Princípios Fundamentais:**
1. **🎓 EDUCAÇÃO**: Ensinar, não apenas instruir
2. **🌟 CLAREZA**: Simplicidade e navegação intuitiva  
3. **🚀 EXPERIÊNCIA**: Foco no usuário e cenários reais
4. **🔄 MANUTENÇÃO**: Modular e sempre atualizado

### **📋 Estrutura Obrigatória:**
- **READMEs**: Template padrão com início rápido
- **Comentários**: Educativos e contextuais
- **Linguagem**: Português brasileiro, tom amigável
- **Templates**: Consistentes e reutilizáveis

### **🎯 Objetivo Final:**
**Documentação que ensina Kubernetes através de charts funcionais, não que impressiona com complexidade técnica!**

---

**💡 Lembre-se:** Boa documentação é aquela que faz o usuário se sentir **capaz e confiante**, não perdido e intimidado! 