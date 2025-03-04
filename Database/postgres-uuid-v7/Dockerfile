# Imagem oficial do PostgreSQL 16
FROM postgres:16
# Argumentos
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB
# Copia o arquivo init-db.sql para a pasta /docker-entrypoint-initdb.d/ do container
COPY init-db.sql /docker-entrypoint-initdb.d/
# Define as variáveis de ambiente
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV POSTGRES_DB=${POSTGRES_DB}
