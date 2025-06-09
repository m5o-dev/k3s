# 📚 Documentação de Charts Simplificados

## 🎯 **Visão Geral**

Esta documentação contém **guidelines, padrões e exemplos** para criar charts Helm **simples e amigáveis** para pessoas aprendendo Kubernetes. 

### **🚀 Nossa Filosofia**
- **Simplicidade primeiro**: Charts fáceis de usar para iniciantes
- **Sem helpers**: Templates diretos, sem `_helpers.tpl`
- **Padronização via documentação**: Guidelines claros em vez de código complexo
- **Experiência progressiva**: Do básico ao avançado

## 📋 **Documentos Principais**

### **1. 📖 [CHART_GUIDELINES.md](./CHART_GUIDELINES.md)**
**O documento principal** com todos os padrões obrigatórios:
- ✅ Estrutura de diretórios
- ✅ Labels padrão (kubernetes.io)
- ✅ Convenções de nomenclatura
- ✅ Padrões de templates
- ✅ Checklist de qualidade

**👥 Para quem:** Desenvolvedores criando novos charts

### **2. ⚙️ [VALUES_PATTERNS.md](./VALUES_PATTERNS.md)**
**Guia completo** para estruturar o `values.yaml`:
- ✅ Estrutura obrigatória (Essencial → Opcional → Avançado)
- ✅ Convenções de nomenclatura
- ✅ Comentários educativos
- ✅ Padrões por tipo de aplicação
- ✅ Melhores práticas

**👥 Para quem:** Todos que trabalham com values.yaml

### **3. 🏥 [HEALTH_CHECKS.md](./HEALTH_CHECKS.md)**
**Guia completo** para health checks e verificações de saúde:
- ✅ Tipos de probes (startup, liveness, readiness)
- ✅ Métodos de verificação (HTTP, TCP, exec)
- ✅ Configurações por tipo de aplicação
- ✅ Troubleshooting e resolução de problemas
- ✅ Implementação step-by-step

**👥 Para quem:** Desenvolvedores implementando aplicações confiáveis

### **4. 🔧 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**
**Guia de resolução** de problemas comuns:
- ✅ Problemas mais frequentes e soluções
- ✅ Comandos de debug essenciais
- ✅ Checklist de verificação rápida
- ✅ Template para reports de problemas
- ✅ Dicas de prevenção

**👥 Para quem:** Todos os usuários, especialmente iniciantes

## 🔧 **Exemplos Práticos**

A pasta [`examples/`](./examples/) contém **templates prontos** para copiar e adaptar:

| Arquivo | Descrição | Uso |
|---------|-----------|-----|
| 📦 **[deployment.yaml](./examples/deployment.yaml)** | Deployment básico | Aplicações em geral |
| 🌐 **[service.yaml](./examples/service.yaml)** | Service padrão | Exposição interna |
| 🚪 **[ingressroute.yaml](./examples/ingressroute.yaml)** | IngressRoute Traefik | Exposição externa |
| ⚙️ **[configmap.yaml](./examples/configmap.yaml)** | ConfigMap | Configurações |
| 🔐 **[secret.yaml](./examples/secret.yaml)** | Secret + Basic Auth | Dados sensíveis |
| 💾 **[pvc.yaml](./examples/pvc.yaml)** | PersistentVolumeClaim | Armazenamento |
| 👤 **[serviceaccount.yaml](./examples/serviceaccount.yaml)** | ServiceAccount + RBAC | Permissões |
| 🛠️ **[middleware.yaml](./examples/middleware.yaml)** | Middlewares Traefik | Auth, CORS, HTTPS |
| 🧪 **[test-pod.yaml](./examples/test-pod.yaml)** | Helm Tests | Validação funcional |

**👥 Para quem:** Desenvolvedores implementando templates

## 🚀 **Como Usar**

### **Para Criar um Novo Chart**

1. **📖 Leia** [CHART_GUIDELINES.md](./CHART_GUIDELINES.md) primeiro
2. **📋 Use** [VALUES_PATTERNS.md](./VALUES_PATTERNS.md) para estruturar o values.yaml
3. **📦 Copie** os exemplos de [`examples/`](./examples/) que precisar
4. **✅ Valide** usando o checklist do guidelines

### **Para Tutoriais/Blog Posts**

1. **🎯 Use** charts da pasta `new-charts/` 
2. **💡 Mostre** comandos simples: `--set domain=app.com`
3. **📚 Referencie** esta documentação para explicações técnicas

## 🎯 **Exemplo de Uso**

```bash
# Simples e intuitivo
helm install bridge new-charts/bridge \
  --set domain=bridge.com
```

## 📊 **Padrões Obrigatórios (Resumo)**

### **🏷️ Labels (em TODOS os recursos)**
```yaml
labels:
  app.kubernetes.io/name: "{{ .Chart.Name }}"
  app.kubernetes.io/instance: "{{ .Release.Name }}"
  app.kubernetes.io/version: "{{ .Chart.AppVersion | quote }}"
  app.kubernetes.io/component: "{{ .Values.component | default \"application\" }}"
  app.kubernetes.io/part-of: "{{ .Chart.Name }}"
  app.kubernetes.io/managed-by: "{{ .Release.Service }}"
```

### **📛 Nomenclatura**
- **Nome dos recursos**: `{{ .Release.Name }}-{{ .Chart.Name }}`
- **Selector**: `app.kubernetes.io/name` + `app.kubernetes.io/instance`
- **Namespace**: `{{ .Release.Namespace }}`

### **📁 Values.yaml**
```yaml
# 🚀 CONFIGURAÇÃO ESSENCIAL (topo)
domain: "app.exemplo.com"
image: {...}
resources: {...}

# ⚡ FUNCIONALIDADES OPCIONAIS (meio)
auth: {...}
tls: {...}

# 🔧 CONFIGURAÇÃO AVANÇADA (bottom)
advanced: {...}
```

## ✅ **Checklist Rápido**

- [ ] **Labels**: Todas as 6 labels kubernetes.io
- [ ] **Nomes**: `{{ .Release.Name }}-{{ .Chart.Name }}`
- [ ] **Values**: Estrutura Essencial → Opcional → Avançado
- [ ] **Comentários**: Explicativos e educativos
- [ ] **Defaults**: Funcionam out-of-the-box
- [ ] **Teste**: `helm template` funciona
- [ ] **Experiência**: `--set domain=app.com` funciona

## 📈 **Benefícios**

### **👶 Para Iniciantes**
✅ Comandos simples de lembrar  
✅ Configuração intuitiva  
✅ Documentação clara  
✅ Troubleshooting direto  

### **📝 Para Tutoriais**
✅ Fácil de explicar  
✅ Foco no Kubernetes, não no Helm  
✅ Exemplos reproduzíveis  
✅ Comandos limpos para blog posts  

### **🛠️ Para Manutenção**
✅ Templates diretos (sem helpers)  
✅ Padrões documentados  
✅ Fácil de debugar  
✅ Consistência entre charts  

## 🤝 **Contribuindo**

1. **📖 Siga** os guidelines rigorosamente
2. **📝 Documente** decisões de design
3. **🧪 Teste** a experiência do usuário
4. **💡 Proponha** melhorias nos padrões

## 📞 **Suporte**

- **🐛 Issues**: Para bugs nos guidelines ou exemplos
- **💡 Discussões**: Para propostas de melhorias
- **📚 Tutoriais**: Consulte charts em `new-charts/`

---

**💡 Dica**: Comece sempre com [CHART_GUIDELINES.md](./CHART_GUIDELINES.md) e use os [exemplos](./examples/) como base! 