# 🐘 PostgreSQL - Helm Chart Simplificado

**Banco de dados PostgreSQL** altamente configurável para desenvolvimento e produção.

## 🏗️ **Arquitetura**

```mermaid
flowchart TD
    App["🔌 Aplicação"] --> Service["🔗 Service<br/>(Port 5432)"]
    
    Service --> Deployment["🚀 Deployment<br/>(PostgreSQL Server)"]
    
    Secret["🔐 Secret<br/>(Credentials)"] -.-> Deployment
    PVC[("💾 PVC<br/>(Database Storage)")] -.-> Deployment
    ConfigMap["⚙️ ConfigMap<br/>(Performance Config)"] -.-> Deployment
    
    classDef serviceStyle fill:#22c55e,stroke:#16a34a,color:#fff
    classDef deploymentStyle fill:#14b8a6,stroke:#0d9488,color:#fff
    classDef secretStyle fill:#f43f5e,stroke:#e11d48,color:#fff
    classDef storageStyle fill:#0ea5e9,stroke:#0284c7,color:#fff
    classDef configStyle fill:#f59e0b,stroke:#d97706,color:#fff
    classDef defaultStyle fill:#78716c,stroke:#57534e,color:#fff
    
    class Service serviceStyle
    class Deployment deploymentStyle
    class Secret secretStyle
    class PVC storageStyle
    class ConfigMap configStyle
    class App defaultStyle
```

**Recursos criados por este chart:**
- 🔗 **Service**: Exposição interna do PostgreSQL (port 5432)
- 🚀 **Deployment**: Container PostgreSQL server
- 🔐 **Secret**: Credenciais (POSTGRES_USER/PASSWORD/DB)
- 💾 **PVC**: Armazenamento persistente para banco de dados
- ⚙️ **ConfigMap**: Configurações de performance (modo avançado)

**Conexão disponível:**
- 📦 **PostgreSQL**: `<release-name>-postgresql.<namespace>.svc.cluster.local:5432`

## 🚀 **Instalação Rápida**

### **Básica (recomendada)**
```bash
helm install postgres charts/postgresql \
  --set auth.password=minhasenhasegura123 \
  --create-namespace \
  --namespace postgres
```

### **Com banco específico**
```bash
helm install postgres charts/postgresql \
  --set auth.password=minhasenhasegura123 \
  --set auth.database=meuapp \
  --create-namespace \
  --namespace postgres
```

### **Para produção**
```bash
helm install postgres charts/postgresql \
  --set auth.password=senha-ultra-segura \
  --set auth.database=producao \
  --set storage.size=100Gi \
  --set storage.storageClass=fast-ssd \
  --set resources.limits.cpu=2000m \
  --set resources.limits.memory=4Gi \
  --create-namespace \
  --namespace postgres
```

## ⚙️ **Configurações Principais**

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `auth.username` | Usuário administrador | `postgres` |
| `auth.password` | **Senha obrigatória** | `""` (deve ser definida) |
| `auth.database` | Banco de dados inicial | `""` (opcional) |
| `storage.size` | Tamanho do volume persistente | `10Gi` |
| `storage.storageClass` | Classe de armazenamento | `""` (padrão) |
| `resources.limits.cpu` | CPU máxima | `1000m` |
| `resources.limits.memory` | Memória máxima | `2Gi` |

## 🔧 **Configurações Avançadas**

### **Habilitando configurações avançadas**
```bash
helm install postgres charts/postgresql \
  --set auth.password=senha123 \
  --set advanced.enabled=true \
  --set advanced.postgresql.config.shared_buffers=512MB \
  --create-namespace \
  --namespace postgres
```

### **📊 Principais configurações avançadas disponíveis**

#### **🖼️ Configurações de Imagem**
| Parâmetro | Descrição | Padrão |
|-----------|-----------|---------|
| `advanced.postgresql.image.repository` | Repositório da imagem | `postgres` |
| `advanced.postgresql.image.tag` | Tag da imagem | `17.2` |
| `advanced.postgresql.image.pullPolicy` | Política de pull da imagem | `IfNotPresent` |

#### **⚡ Configurações de Performance**
| Parâmetro | Descrição | Padrão |
|-----------|-----------|---------|
| `advanced.postgresql.config.max_connections` | Conexões máximas | `100` |
| `advanced.postgresql.config.shared_buffers` | Buffer compartilhado | `256MB` |
| `advanced.postgresql.config.effective_cache_size` | Cache efetivo | `768MB` |
| `advanced.postgresql.config.work_mem` | Memória para operações | `4MB` |

#### **🩺 Configurações de Health Checks**
| Parâmetro | Descrição | Padrão |
|-----------|-----------|---------|
| `advanced.postgresql.health.liveness.enabled` | Habilitar liveness probe | `true` |
| `advanced.postgresql.health.readiness.enabled` | Habilitar readiness probe | `true` |

#### **🔐 Configurações de Segurança**
| Parâmetro | Descrição | Padrão |
|-----------|-----------|---------|
| `advanced.postgresql.security.runAsUser` | UID do usuário do container | `999` |
| `advanced.postgresql.security.runAsGroup` | GID do grupo do container | `999` |
| `advanced.postgresql.security.fsGroup` | Grupo do filesystem | `999` |

### **💡 Exemplos de uso avançado**

#### **🚀 Para alta performance**
```bash
helm install postgres charts/postgresql \
  --set auth.password=senha123 \
  --set advanced.enabled=true \
  --set advanced.postgresql.config.shared_buffers=1GB \
  --set advanced.postgresql.config.effective_cache_size=3GB \
  --set advanced.postgresql.config.max_connections=200 \
  --set advanced.postgresql.config.work_mem=8MB \
  --set storage.size=500Gi \
  --set resources.limits.cpu=4000m \
  --set resources.limits.memory=8Gi \
  --create-namespace \
  --namespace postgres
```

#### **🔒 Com configurações de segurança**
```bash
helm install postgres charts/postgresql \
  --set auth.password=senha123 \
  --set advanced.enabled=true \
  --set advanced.postgresql.security.runAsUser=1001 \
  --set advanced.postgresql.persistence.retainOnDelete=true \
  --create-namespace \
  --namespace postgres
```

#### **📊 Com scripts de inicialização**
```bash
helm install postgres charts/postgresql \
  --set auth.password=senha123 \
  --set auth.database=meuapp \
  --set advanced.enabled=true \
  --set-file advanced.postgresql.initdb.scripts."01-extensions\.sql"=./extensions.sql \
  --create-namespace \
  --namespace postgres
```

**Exemplo de script SQL (`extensions.sql`):**
```sql
-- Habilitar extensões úteis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Criar usuário da aplicação
CREATE USER app_user WITH PASSWORD 'app_password';
GRANT ALL PRIVILEGES ON DATABASE meuapp TO app_user;
```

## 🔍 **Verificação da Instalação**

```bash
# Verificar pods
kubectl get pods -n postgres

# Verificar serviços
kubectl get svc -n postgres

# Verificar PVC
kubectl get pvc -n postgres

# Verificar logs
kubectl logs -l app.kubernetes.io/name=postgresql -n postgres
```

## 🔌 **Teste de Conexão**

### **Via kubectl (temporário)**
```bash
# Conectar no banco usando psql
kubectl run postgresql-client --rm --tty -i --restart='Never' \
  --namespace postgres \
  --image postgres:17.2 \
  --env="PGPASSWORD=minhasenhasegura123" \
  --command -- psql --host postgres-postgresql --username postgres --dbname postgres

# Testar conectividade básica
kubectl run postgresql-test --rm --tty -i --restart='Never' \
  --namespace postgres \
  --image postgres:17.2 \
  --env="PGPASSWORD=minhasenhasegura123" \
  --command -- psql --host postgres-postgresql --username postgres --dbname postgres -c "SELECT version();"
kubectl run postgresql-client --rm --tty -i --restart='Never' \
  --namespace postgres \
  --image postgres:17.2 \
  --env="PGPASSWORD=minhasenhasegura123" \
  --command -- psql --host postgresql-postgresql --username postgres -p 5432

# Dentro do psql:
# \l                    # Listar bancos
# \c nome_banco         # Conectar em banco específico
# \dt                   # Listar tabelas
# \q                    # Sair
```

### **Via aplicação interna**
```yaml
# Exemplo de conexão em uma aplicação
apiVersion: v1
kind: Pod
metadata:
  name: app-example
spec:
  containers:
  - name: app
    image: alpine:latest
    env:
    - name: DATABASE_URL
      value: "postgresql://postgres:minhasenhasegura123@postgresql-postgresql.postgres.svc.cluster.local:5432/postgres"
    command: ["sleep", "3600"]
```

### **String de conexão padrão**
```
Host: postgresql-postgresql.postgres.svc.cluster.local
Port: 5432
User: postgres
Password: [auth.password]
Database: [auth.database] (ou 'postgres' se não especificado)
```

## 🐛 **Troubleshooting**

### **Pod não inicializa**
```bash
# Verificar status do pod
kubectl describe pod -l app.kubernetes.io/name=postgresql -n postgres

# Verificar logs do container
kubectl logs -l app.kubernetes.io/name=postgresql -n postgres

# Verificar se PVC foi criado
kubectl describe pvc postgresql-postgresql-data -n postgres
```

### **Problemas de conexão**
```bash
# Testar conectividade interna
kubectl run pg-test --rm --tty -i --restart='Never' \
  --namespace postgres \
  --image busybox \
  --command -- nc -zv postgresql-postgresql 5432

# Verificar service e endpoints
kubectl get svc,endpoints -n postgres
```

### **Problemas de autenticação**
```bash
# Verificar secret com credenciais
kubectl get secret postgresql-postgresql-credentials -n postgres -o yaml

# Decodificar credenciais
kubectl get secret postgresql-postgresql-credentials -n postgres -o jsonpath='{.data.POSTGRES_USER}' | base64 -d
kubectl get secret postgresql-postgresql-credentials -n postgres -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d
```

### **Performance baixa**
```bash
# Verificar configurações de recursos
kubectl describe pod -l app.kubernetes.io/name=postgresql -n postgres | grep -A 10 Resources

# Verificar configurações do PostgreSQL (modo avançado)
kubectl get configmap postgresql-postgresql-config -n postgres -o yaml
```

### **PVC não pode ser montado**
```bash
# Verificar StorageClass
kubectl get storageclass

# Verificar se há espaço disponível nos nodes
kubectl describe nodes | grep -A5 "Allocated resources"

# Verificar eventos do PVC
kubectl describe pvc postgresql-postgresql-data -n postgres
```

## ✅ **Teste de Validação Completa**

Use este comando para verificar se tudo está funcionando:

```bash
# 1. Verificar pods rodando
kubectl get pods -n postgres | grep -E "(Running|Completed)"

# 2. Verificar recursos de rede
kubectl get service,endpoints -n postgres

# 3. Verificar armazenamento
kubectl get pvc -n postgres

# 4. Teste de conectividade
kubectl run pg-test --rm --tty -i --restart='Never' \
  --namespace postgres \
  --image postgres:17.2 \
  --env="PGPASSWORD=minhasenhasegura123" \
  --command -- pg_isready --host postgresql-postgresql --username postgres

# 5. Teste de operação SQL básica
kubectl run pg-client --rm --tty -i --restart='Never' \
  --namespace postgres \
  --image postgres:17.2 \
  --env="PGPASSWORD=minhasenhasegura123" \
  --command -- psql --host postgresql-postgresql --username postgres \
  -c "SELECT version();"
```

## 📚 **Recursos Úteis**

- 🐘 **PostgreSQL Official**: [PostgreSQL.org](https://www.postgresql.org/)
- 📖 **Documentação**: [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- 🔧 **Tuning Guide**: [PGTune](https://pgtune.leopard.in.ua/)
- 🎯 **Use Cases**: Ideal para aplicações web, data analytics, OLTP, JSON
- 🔍 **Monitoring**: Considere usar pg_stat_statements, pgbadger
- 🚀 **Extensions**: PostGIS, TimescaleDB, pg_cron disponíveis

## ⚠️ **Requisitos**

- **Kubernetes**: 1.21+
- **Storage**: Classe de armazenamento com suporte a ReadWriteOnce
- **Memória**: Mínimo 512Mi por instância
- **CPU**: Mínimo 250m por instância
- **Disco**: Espaço conforme `storage.size` configurado
- **PostgreSQL**: Versão 17.2 LTS (mais recente estável)

## 🎛️ **Comparação com Chart Antigo**

Esta versão do chart **migrou do boilerplate** para implementação direta:

✅ **Versão Atualizada**: `13.4` → **`17.2`** (4 major versions mais recente!)  
✅ **Interface Simplificada**: Apenas `auth.password` obrigatória  
✅ **Recursos**: Secret, Deployment, Service, PVC, ConfigMap (opcional)  
✅ **Labels Kubernetes**: Padrão completo aplicado  
✅ **Configurações Avançadas**: Performance, segurança, scripts init  
✅ **Health Checks**: Liveness e readiness probes otimizados  
✅ **Segurança**: Contextos de segurança e retenção de dados  

---

💡 **Dica**: Para desenvolvimento, use volumes pequenos (`storage.size=10Gi`). Para produção, sempre configure `advanced.postgresql.persistence.retainOnDelete=true` e backups regulares! 