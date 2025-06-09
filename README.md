# 🚀 Charts Helm para k3s

> **Helm Charts** customizados e otimizados para cluster k3s pessoal.

## 📦 **Charts Disponíveis**

| Chart | Versão | Comando de Instalação |
|-------|--------|---------------------|
| 🔴 **Redis** | 7.4.1 | `helm install redis charts/redis --set auth.password=senha123` |
| 🐘 **PostgreSQL** | - | `helm install postgres charts/postgresql --set domain=db.local` |
| 📦 **MinIO** | - | `helm install minio charts/minio --set domain=s3.local` |
| 💾 **Longhorn** | - | `helm install longhorn charts/longhorn` |
| 🚢 **Harbor** | - | `helm install harbor charts/harbor --set domain=registry.local` |
| 🌉 **Bridge** | - | `helm install bridge charts/bridge --set domain=bridge.local` |

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