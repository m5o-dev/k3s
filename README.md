# 🚀 Charts Helm para k3s

> **Helm Charts** customizados e otimizados para cluster k3s pessoal.

## 📦 **Charts Disponíveis**

| Chart | Descrição |
|-------|-----------|
| 🔴 **Redis** | Cache in-memory para sessões e dados temporários |
| 🐘 **PostgreSQL** | Banco de dados relacional para aplicações |
| 📦 **MinIO** | Object storage compatível com S3 |
| 💾 **Longhorn** | Storage distribuído para volumes persistentes |
| 🚢 **Harbor** | Registry privado para containers |
| 🌉 **Bridge** | Aplicação de ponte para acesso ao cluster |

## 🚀 **Instalação Rápida**

```bash
# 1. Clone o repositório
git clone <repository-url>
cd k3s

# 2. Instale um chart
helm install <nome> charts/<chart> --set domain=<seu-dominio>

# 3. Verifique o deployment
kubectl get pods -l app.kubernetes.io/name=<chart>
```

## 📁 **Estrutura**

```
k3s/
├── 📦 charts/              # Helm Charts
├── 📚 docs/               # Documentação e guidelines
└── 🤖 prompts/            # Configurações de IA
```

## 📚 **Documentação**

- **[docs/CHART_GUIDELINES.md](./docs/CHART_GUIDELINES.md)** - Padrões obrigatórios
- **[docs/CHART_NAMING_STANDARDS.md](./docs/CHART_NAMING_STANDARDS.md)** - Labels e nomenclatura
- **[docs/CHART_VALUES_GUIDE.md](./docs/CHART_VALUES_GUIDE.md)** - Estrutura do values.yaml
- **[docs/CHART_DOCUMENTATION_GUIDE.md](./docs/CHART_DOCUMENTATION_GUIDE.md)** - Guia de documentação
- **[docs/CHART_TESTING_GUIDE.md](./docs/CHART_TESTING_GUIDE.md)** - Estratégia de testes
- **[docs/CHART_TROUBLESHOOTING.md](./docs/CHART_TROUBLESHOOTING.md)** - Resolução de problemas
- **[docs/CHART_HEALTH_CHECKS.md](./docs/CHART_HEALTH_CHECKS.md)** - Verificações de saúde
- **[docs/examples/](./docs/examples/)** - Templates prontos

## 🔧 **Padrões**

### **Labels Obrigatórios (6)**
```yaml
app.kubernetes.io/name: "{{ .Chart.Name }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: "application"
app.kubernetes.io/part-of: "{{ .Chart.Name }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
```

### **Estrutura Values.yaml**
```yaml
# 🚀 CONFIGURAÇÃO ESSENCIAL
domain: "app.exemplo.com"
image: {...}
resources: {...}

# ⚡ FUNCIONALIDADES OPCIONAIS  
auth: {...}
tls: {...}

# 🔧 CONFIGURAÇÃO AVANÇADA
advanced: {...}
```

## 🧪 **Testes**

```bash
# Validar sintaxe
helm lint charts/<chart>

# Testar templates
helm template test charts/<chart> --set domain=test.com

# Executar testes funcionais
helm test <release> -n <namespace>
```

## 🎯 **Filosofia**

- **Simplicidade primeiro** - Charts fáceis de usar
- **Padronização** - Guidelines claros e consistentes  
- **Experiência progressiva** - Do básico ao avançado
- **Foco em k3s** - Otimizado para ambientes lightweight

---

**📖 Para mais detalhes**, consulte a [documentação completa](./docs/README.md)

**🚀 Mantido por**: Marcelo | **📧 Issues**: [Abra aqui](../../issues) 