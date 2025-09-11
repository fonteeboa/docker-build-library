# SonarQube Community local — Compose com **postgres**, **sonarqube** e **sonar-scanner**

Este guia sobe um ambiente local com **SonarQube Community + PostgreSQL** e já inclui um **serviço do Sonar Scanner** dentro do próprio `docker compose`, facilitando a análise de qualquer repositório montado na raiz do projeto.

> Compatível com Windows 11 (Docker Desktop/WSL2), macOS e Linux.

---

## Sumário

- [SonarQube Community local — Compose com **postgres**, **sonarqube** e **sonar-scanner**](#sonarqube-community-local--compose-com-postgres-sonarqube-e-sonar-scanner)
  - [Sumário](#sumário)
  - [Pré‑requisitos](#prérequisitos)
  - [Arquitetura](#arquitetura)
  - [Compose (copie e cole)](#compose-copie-e-cole)
  - [Subir \& acessar](#subir--acessar)
  - [Primeiro acesso \& Token](#primeiro-acesso--token)
  - [Rodar o scan com o serviço `sonar-scanner`](#rodar-o-scan-com-o-serviço-sonar-scanner)
  - [Exemplo de `sonar-project.properties` (JS/TS)](#exemplo-de-sonar-projectproperties-jsts)
  - [Cobertura (Jest) em Node/TS](#cobertura-jest-em-nodets)
  - [Maven (Java)](#maven-java)
  - [Boas práticas](#boas-práticas)
  - [Troubleshooting](#troubleshooting)
  - [Parar \& limpar](#parar--limpar)

---

## Pré‑requisitos

* **Docker** + **Docker Compose** instalados
* **Porta 9000** livre no host
* **2–4 GB de RAM livres** (quanto mais, melhor)
* **Linux**: este compose define `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true` (DEV). Se remover essa flag, garanta no host:

  ```bash
  sudo sysctl -w vm.max_map_count=262144
  echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
  ```

---

## Arquitetura

* **postgres**: banco PostgreSQL 15 (volume `sonar_db_data`)
* **sonarqube**: aplicação + Elasticsearch (volumes `sonar_data`, `sonar_extensions`)
* **sonar-scanner**: CLI oficial do scanner já na mesma rede (`sonarnet`) e com `./` montado em `/usr/src`

Rede dedicada: `sonarnet` (bridge)

---

## Compose (copie e cole)

Salve como `docker-compose.yml` na raiz do seu repositório:

```yaml
services:
  postgres:
    image: postgres:15
    container_name: sonarqube-db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonarqube
    volumes:
      - sonar_db_data:/var/lib/postgresql/data
    networks:
      - sonarnet

  sonarqube:
    image: sonarqube:25.7.0.110598-community
    container_name: sonarqube
    depends_on:
      - postgres
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://postgres:5432/sonarqube
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "true"
    volumes:
      - sonar_data:/opt/sonarqube/data
      - sonar_extensions:/opt/sonarqube/extensions
    networks:
      - sonarnet

  sonar-scanner:
    image: sonarsource/sonar-scanner-cli:latest
    container_name: sonar-scanner
    depends_on:
      - sonarqube
    working_dir: /usr/src
    volumes:
      - ./:/usr/src
    environment:
      SONAR_HOST_URL: "http://sonarqube:9000"
      SONAR_SCANNER_OPTS: "-Dsonar.verbose=true"
    networks:
      - sonarnet
    entrypoint: ["sleep", "infinity"]


volumes:
  sonar_db_data:
  sonar_data:
  sonar_extensions:

networks:
  sonarnet:
    driver: bridge
```

> **Notas**
>
> * A tag de imagem `sonarqube:25.7.0.110598-community` foi adotada conforme solicitado. Você pode trocar por uma LTS estável (ex.: `sonarqube:9.9-community` ou versão recente suportada) se preferir.
> * `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true` é **somente para DEV/lab**. Em produção, remova e ajuste `vm.max_map_count` no host.

---

## Subir & acessar

```bash
docker compose up -d          # sobe postgres, sonarqube e sonar-scanner
# ou, se preferir, apenas os serviços base
# docker compose up -d postgres sonarqube
```

Acesse a UI: [http://localhost:9000](http://localhost:9000)

Se a porta 9000 estiver ocupada, altere `"9001:9000"` nos `ports` do serviço `sonarqube`.

---

## Primeiro acesso & Token

1. Login inicial: **admin / admin** (você terá que trocar a senha).
2. Gere um **Token pessoal**: avatar (canto superior direito) → **My Account** → **Security** → **Generate Tokens**. Guarde-o (aparece uma só vez).

---

## Rodar o scan com o serviço `sonar-scanner`

O serviço `sonar-scanner` já monta **a raiz do repo** em `/usr/src`. Crie um `sonar-project.properties` na raiz do seu projeto com a configuração mínima e execute:

```bash
docker compose exec -e SONAR_TOKEN=SEU_TOKEN_AQUI sonar-scanner \
  sonar-scanner -Dsonar.login=$SONAR_TOKEN
```

* Dentro da rede, o scanner fala com `http://sonarqube:9000` (definido em `SONAR_HOST_URL`).
* Para **propriedades extras** na linha de comando:

  ```bash
  docker compose exec -e SONAR_TOKEN=SEU_TOKEN_AQUI sonar-scanner \
    sonar-scanner \
      -Dsonar.login=$SONAR_TOKEN \
      -Dsonar.projectKey=meu-projeto \
      -Dsonar.projectName="Meu Projeto"
  ```
* Se você gerar cobertura (ex.: Jest → `coverage/lcov.info`), execute os testes **antes** do scanner.

> **Dica**: você também pode "entrar" no container e rodar múltiplos comandos:
>
> ```bash
> docker compose exec sonar-scanner sh
> # já dentro do container:
> sonar-scanner -Dsonar.login=SEU_TOKEN_AQUI
> ```

---

## Exemplo de `sonar-project.properties` (JS/TS)

Crie este arquivo na raiz do projeto:

```properties
# Identidade
sonar.projectKey=meu-projeto
sonar.projectName=Meu Projeto
sonar.projectVersion=1.0.0

# Fontes e exclusões
sonar.sources=src
sonar.exclusions=**/node_modules/**,**/dist/**,**/build/**

# Testes e cobertura (Jest)
sonar.tests=src
sonar.test.inclusions=**/*.test.* , **/*.spec.*
sonar.javascript.lcov.reportPaths=coverage/lcov.info

# TypeScript
sonar.typescript.tsconfigPath=tsconfig.json
```

---

## Cobertura (Jest) em Node/TS

No `package.json`:

```json
{
  "scripts": {
    "test:coverage": "jest --coverage"
  },
  "jest": {
    "collectCoverage": true,
    "coverageDirectory": "coverage",
    "coverageReporters": ["lcov", "text", "json"]
  }
}
```

Rode:

```bash
npm run test:coverage # (ou yarn/pnpm)
docker compose exec -e SONAR_TOKEN=SEU_TOKEN_AQUI sonar-scanner \
  sonar-scanner -Dsonar.login=$SONAR_TOKEN
```

---

## Maven (Java)

No `pom.xml`:

```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.sonarsource.scanner.maven</groupId>
      <artifactId>sonar-maven-plugin</artifactId>
      <version>3.10.0.2594</version>
    </plugin>
  </plugins>
</build>
```

Rode:

```bash
mvn clean verify
mvn sonar:sonar -Dsonar.host.url=http://localhost:9000 -Dsonar.login=SEU_TOKEN_AQUI
```

---

## Boas práticas

* Quebre o **pipeline** quando o **Quality Gate** falhar.
* Para monorepos, um `sonar-project.properties` por app/lib (chaves distintas).
* Mantenha `sonar.projectKey` estável (evita duplicar histórico).
* Aplique **exclusions** para diretórios gerados e vendor.

---

## Troubleshooting

* **UI não abre (localhost:9000)**: `docker compose ps`, `docker compose logs -f sonarqube`.
* **Porta ocupada**: ajuste `ports` do serviço `sonarqube`.
* **Elasticsearch/Bootstrap**: a flag `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true` é só para DEV. Sem ela, configure `vm.max_map_count` no host Linux.
* **Banco**: `docker compose logs -f sonarqube-db`; confira `jdbc:postgresql://postgres:5432/sonarqube`.
* **Scanner não autentica**: gere um novo token e tente novamente.
* **Cobertura não aparece**: verifique se `coverage/lcov.info` existe e se o caminho está correto no `.properties`.

---

## Parar & limpar

```bash
docker compose down            # para os serviços
docker compose down -v         # também remove volumes (ATENÇÃO: perde dados e histórico)
```
