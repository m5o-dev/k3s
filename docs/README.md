# 📚 Documentação de Charts Simplificados

## 🎯 **Visão Geral**

Esta documentação contém **guidelines, padrões e exemplos** para criar charts Helm **simples e amigáveis** para pessoas aprendendo Kubernetes. 

### **🚀 Nossa Filosofia**
- **Simplicidade primeiro**: Charts fáceis de usar para iniciantes
- **Sem helpers**: Templates diretos, sem `_helpers.tpl`
- **Padronização via documentação**: Guidelines claros em vez de código complexo
- **Experiência progressiva**: Do básico ao avançado

## 📋 **Documentos Principais**

### **📚 Filosofia e Estrutura**

#### **1. 📖 [CHART_GUIDELINES.md](./CHART_GUIDELINES.md)**
**Filosofia e estrutura** de charts - documento central:
- ✅ Objetivos e princípios fundamentais
- ✅ Estrutura de diretórios
- ✅ Templates padrão essenciais
- ✅ Checklist de qualidade
- ✅ Referências para documentação específica

**👥 Para quem:** Desenvolvedores criando novos charts

#### **2. 🏷️ [CHART_NAMING_STANDARDS.md](./CHART_NAMING_STANDARDS.md)**
**Padrões de nomenclatura e labels** - referência obrigatória:
- ✅ 6 labels obrigatórias kubernetes.io
- ✅ Convenções de nomenclatura
- ✅ Estrutura completa do values.yaml
- ✅ Sintaxe correta do Helm
- ✅ Comandos de verificação

**👥 Para quem:** Todos os desenvolvedores - referência essencial

#### **3. ⚙️ [CHART_VALUES_GUIDE.md](./CHART_VALUES_GUIDE.md)**
**Padrões específicos** para values.yaml:
- ✅ Padrões por tipo de aplicação
- ✅ Configurações específicas
- ✅ Exemplos práticos
- ✅ Melhores práticas

**👥 Para quem:** Desenvolvedores configurando charts específicos

#### **4. 📚 [CHART_DOCUMENTATION_GUIDE.md](./CHART_DOCUMENTATION_GUIDE.md)**
**Guia prático de documentação** - baseado nos charts existentes:
- ✅ Estrutura testada de READMEs
- ✅ Diagramas Mermaid padronizados
- ✅ Comentários educativos no values.yaml
- ✅ Exemplos funcionais copy-paste
- ✅ Checklist de qualidade

**👥 Para quem:** Todos - documentação prática e funcional

### **🔧 Implementação e Operação**

#### **5. 🩺 [CHART_HEALTH_CHECKS.md](./CHART_HEALTH_CHECKS.md)**
**Guia completo** para health checks:
- ✅ Tipos de probes (startup, liveness, readiness)
- ✅ Métodos de verificação (HTTP, TCP, exec)
- ✅ Configurações por tipo de aplicação
- ✅ Troubleshooting específico
- ✅ Implementação step-by-step

**👥 Para quem:** Desenvolvedores implementando aplicações confiáveis

#### **6. 🚨 [CHART_TROUBLESHOOTING.md](./CHART_TROUBLESHOOTING.md)**
**Guia de resolução** de problemas comuns:
- ✅ 5 problemas mais frequentes
- ✅ Comandos de debug essenciais
- ✅ Checklist de verificação rápida
- ✅ Template para reports
- ✅ Dicas de prevenção

**👥 Para quem:** Operadores e usuários - resolução de problemas

### **🧪 Testes e Qualidade**

#### **7. 🧪 [CHART_TESTING_GUIDE.md](./CHART_TESTING_GUIDE.md)**
**Estratégia completa** de testes e validação:
- ✅ Filosofia e metodologia de testes
- ✅ Múltiplas camadas de validação
- ✅ CI/CD integration
- ✅ Ferramentas recomendadas
- ✅ Métricas de qualidade

**👥 Para quem:** DevOps e desenvolvedores - qualidade e confiabilidade

#### **8. 🧪 [scripts/test-chart/](../scripts/test-chart/README.md)**
**Scripts automatizados** de teste:
- ✅ Script completo de validação
- ✅ Testes em múltiplas camadas
- ✅ Cleanup automático
- ✅ Integração com CI/CD
- ✅ Debug e troubleshooting

**👥 Para quem:** DevOps - automação de testes

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
2. **📋 Use** [CHART_VALUES_GUIDE.md](./CHART_VALUES_GUIDE.md) para estruturar o values.yaml
3. **📦 Copie** os exemplos de [`examples/`](./examples/) que precisar
4. **✅ Valide** usando o checklist do guidelines

### **Para Tutoriais/Blog Posts**

1. **🎯 Use** charts da pasta `charts/` 
2. **💡 Mostre** comandos simples: `--set domain=app.com`
3. **📚 Referencie** esta documentação para explicações técnicas

## 🎯 **Exemplo de Uso**

```bash
# Simples e intuitivo
helm install bridge charts/bridge \
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
domain: "app.meusite.com"
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
- **📚 Tutoriais**: Consulte charts em `charts/`

---

**💡 Dica**: Comece sempre com [CHART_GUIDELINES.md](./CHART_GUIDELINES.md) e use os [exemplos](./examples/) como base! 