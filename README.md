# 🚀 Repositório K3s - Charts, Pipelines e Recursos

> **Repositório centralizado** para manter charts Helm, pipelines e recursos utilizados no cluster K3s pessoal.

## 📋 **Visão Geral**

Este repositório contém uma coleção organizada de:
- **🎯 Helm Charts** customizados e otimizados para K3s
- **📋 Pipelines** e automações
- **🛠️ Recursos** e configurações do cluster
- **📚 Documentação** completa e educativa

### **🎨 Filosofia do Projeto**
- **Simplicidade primeiro**: Charts fáceis de usar e entender
- **Padronização**: Guidelines claros e consistentes
- **Experiência progressiva**: Do básico ao avançado
- **Foco em K3s**: Otimizado para ambientes lightweight

## 📂 **Estrutura do Repositório**

```
k3s/
├── 📦 charts/              # Helm Charts customizados
│   ├── redis/             # Cache Redis in-memory
│   ├── postgresql/        # Banco de dados PostgreSQL
│   ├── minio/             # Object Storage S3-compatible
│   ├── longhorn/          # Storage distribuído
│   ├── harbor/            # Container Registry
│   └── bridge/            # Aplicação Bridge
├── 📚 docs/               # Documentação completa
│   ├── CHART_GUIDELINES.md    # Guidelines obrigatórios
│   ├── VALUES_PATTERNS.md     # Padrões para values.yaml
│   ├── examples/              # Templates prontos
│   └── use-cases/             # Casos de uso práticos
└── 🤖 .ai/               # Configurações de IA
    ├── personality.md     # Personalidade do assistente
    └── default.md         # Instruções padrão
```

## 🎯 **Charts Disponíveis**

### **🔴 Redis** - Cache In-Memory
```bash
helm install redis charts/redis --set domain=redis.local
```
- **Versão**: 7.4.1
- **Uso**: Cache, sessões, pub/sub
- **Configurações**: Persistência, clustering, monitoramento

### **🐘 PostgreSQL** - Banco de Dados
```bash
helm install postgres charts/postgresql --set domain=db.local
```
- **Uso**: Banco principal, analytics, logs
- **Features**: Backup automático, replicação, extensões

### **📦 MinIO** - Object Storage
```bash
helm install minio charts/minio --set domain=s3.local
```
- **Uso**: Armazenamento de arquivos, backups, dados
- **Compatível**: API S3, integração com apps

### **💾 Longhorn** - Storage Distribuído
```bash
helm install longhorn charts/longhorn
```
- **Uso**: Volumes persistentes distribuídos
- **Features**: Snapshots, backup, replicação

### **🚢 Harbor** - Container Registry
```bash
helm install harbor charts/harbor --set domain=registry.local
```
- **Uso**: Registry privado, scan de vulnerabilidades
- **Features**: RBAC, replicação, webhook

### **🌉 Bridge** - Aplicação Custom
```bash
helm install bridge charts/bridge --set domain=bridge.local
```
- **Uso**: Aplicação específica do projeto
- **Configurável**: Domínio, recursos, integração

## 🚀 **Como Usar**

### **1. Pré-requisitos**
- Cluster K3s rodando
- Helm 3.x instalado
- kubectl configurado

### **2. Instalação Rápida**
```bash
# Clone o repositório
git clone <repository-url>
cd k3s

# Instale um chart
helm install <nome> charts/<chart> --set domain=<seu-dominio>

# Verifique o deployment
kubectl get pods -l app.kubernetes.io/name=<chart>
```

### **3. Personalização**
```bash
# Copie e edite o values.yaml
cp charts/<chart>/values.yaml my-values.yaml

# Instale com valores customizados
helm install <nome> charts/<chart> -f my-values.yaml
```

## 📚 **Documentação**

### **📖 Principais Documentos**
- **[CHART_GUIDELINES.md](./docs/CHART_GUIDELINES.md)**: Padrões obrigatórios para charts
- **[VALUES_PATTERNS.md](./docs/VALUES_PATTERNS.md)**: Estruturação do values.yaml
- **[Exemplos](./docs/examples/)**: Templates prontos para usar

### **🎯 Para Desenvolvedores**
1. Leia os **guidelines** antes de criar charts
2. Use os **padrões** documentados
3. Siga a **estrutura** de values.yaml
4. Teste com o **checklist** de qualidade

### **👥 Para Usuários**
1. Consulte os **READMEs** dos charts
2. Use os **exemplos** como base
3. Personalize via **values.yaml**
4. Monitore via **labels padrão**

## 🔧 **Padrões e Convenções**

### **🏷️ Labels Obrigatórios**
Todos os recursos usam labels kubernetes.io padrão:
```yaml
labels:
  app.kubernetes.io/name: "{{ .Chart.Name }}"
  app.kubernetes.io/instance: "{{ .Release.Name }}"
  app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
  app.kubernetes.io/component: "application"
  app.kubernetes.io/part-of: "{{ .Chart.Name }}"
  app.kubernetes.io/managed-by: "{{ .Release.Service }}"
```

### **📛 Nomenclatura**
- **Recursos**: `{{ .Release.Name }}-{{ .Chart.Name }}`
- **Selectors**: `app.kubernetes.io/name` + `app.kubernetes.io/instance`
- **Namespace**: `{{ .Release.Namespace }}`

### **📁 Estrutura Values**
```yaml
# 🚀 ESSENCIAL (sempre no topo)
domain: "app.exemplo.com"
image: {...}
resources: {...}

# ⚡ OPCIONAL (funcionalidades extras)
auth: {...}
tls: {...}

# 🔧 AVANÇADO (configurações técnicas)
advanced: {...}
```

## 🛠️ **Desenvolvimento e Contribuição**

### **📋 Checklist de Qualidade**
- [ ] Labels kubernetes.io obrigatórios
- [ ] Nomenclatura padronizada
- [ ] Values.yaml estruturado
- [ ] README documentado
- [ ] Templates testados
- [ ] Defaults funcionais

### **🔄 Workflow**
1. **Analise** o chart existente
2. **Implemente** seguindo guidelines
3. **Teste** com `helm template`
4. **Valide** experiência do usuário
5. **Documente** decisões e uso

### **🧪 Testes**
```bash
# Validar templates
helm template charts/<chart>

# Testar instalação
helm install test charts/<chart> --dry-run

# Verificar recursos
kubectl describe <resource>
```

## 🎯 **Casos de Uso**

### **🏠 Homelab**
- Setup completo com storage, registry e monitoramento
- Configuração simplificada via domain

### **🔧 Desenvolvimento**
- Ambiente de dev com bancos e cache
- Integração com CI/CD

### **📊 Produção**
- Deploy com alta disponibilidade
- Monitoramento e observabilidade
- Backup e disaster recovery

## 📞 **Suporte e Manutenção**

### **🐛 Troubleshooting**
```bash
# Verificar status
helm status <release>

# Ver logs
kubectl logs -l app.kubernetes.io/name=<chart>

# Debug recursos
kubectl describe <resource> <name>
```

### **🔄 Atualizações**
```bash
# Atualizar chart
helm upgrade <release> charts/<chart>

# Rollback se necessário
helm rollback <release> <revision>
```

### **📈 Monitoramento**
Todos os charts incluem labels para:
- **Prometheus**: Descoberta automática
- **Grafana**: Dashboards por aplicação
- **Logs**: Agregação estruturada

## 🤝 **Contribuindo**

1. **Fork** o repositório
2. **Crie** uma branch para sua feature
3. **Siga** os guidelines rigorosamente
4. **Teste** a experiência do usuário
5. **Documente** mudanças
6. **Abra** um Pull Request

## 📈 **Roadmap**

- [ ] **Pipelines CI/CD** automatizados
- [ ] **Monitoramento** centralizado
- [ ] **Backup** automático
- [ ] **Security** scanning
- [ ] **Multi-cluster** support

---

**💡 Dica**: Comece sempre lendo a [documentação completa](./docs/) e use os charts como referência para aprender Kubernetes e Helm!

**🚀 Criado em**: Junho 2025  
**🛠️ Mantido por**: Marcelo  
**📧 Contato**: [Abra uma issue](../../issues) para sugestões ou problemas 