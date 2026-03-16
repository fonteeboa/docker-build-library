# Usar uma imagem base com Node.js e ferramentas de build
FROM node:18-bullseye AS builder

# Instalar dependências necessárias para o build
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário para o build (não-root)
RUN groupadd -r builder && useradd -r -g builder -m builder

# Configurar diretório de trabalho
WORKDIR /build

# Clonar o repositório do OpenSearch Dashboards na versão 3.1.0
RUN git clone --depth 1 --branch 3.1.0 https://github.com/opensearch-project/OpenSearch-Dashboards.git .

# Dar permissões ao usuário builder
RUN chown -R builder:builder /build

# Trocar para usuário builder
USER builder

# Instalar dependências
RUN yarn osd bootstrap

# Realizar o build
RUN yarn build --skip-os-packages

# Imagem final mais enxuta
FROM node:18-bullseye-slim

# Instalar dependências de runtime
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root
RUN groupadd -r opensearch && useradd -r -g opensearch -m opensearch

# Configurar diretório de trabalho
WORKDIR /usr/share/opensearch-dashboards

# Copiar todo o diretório de build
COPY --from=builder --chown=opensearch:opensearch /build /usr/share/opensearch-dashboards

# Criar diretórios necessários
RUN mkdir -p data logs && chown -R opensearch:opensearch data logs

# Expor a porta padrão
EXPOSE 5601

# Mudar para usuário não-root
USER opensearch

# Definir NODE_ENV
ENV NODE_ENV=production

# Comando para iniciar o dashboard
CMD ["node", "scripts/opensearch_dashboards", "--host", "0.0.0.0"]