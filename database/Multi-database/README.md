# Multi-Database Dockerfile

This Docker Compose configuration allows you to run multiple databases simultaneously for development and testing environments. Supported databases include PostgreSQL, MySQL, MongoDB, Cassandra, Aurora, Spanner Emulator, and SQLite.

## Supported Databases

- **PostgreSQL**
- **MySQL**
- **MongoDB**
- **Cassandra**
- **Aurora**
- **Google Spanner Emulator**
- **SQLite**

---

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/get-started) installed
- [Docker Compose](https://docs.docker.com/compose/install/) installed

###  Project Structure

```bash
project-root/
├── docker-compose.yml
├── data/ (for SQLite)
└── README.md
```

---

## Configuration (`docker-compose.yml`)

### Activate Databases

You can start specific databases using:

```bash
# Start PostgreSQL and MySQL
docker-compose up postgres mysql

# Start MongoDB and Cassandra
docker-compose up mongodb cassandra

# Start Aurora and Spanner Emulator
docker-compose up aurora spanner-emulator

# Start SQLite only
docker-compose up sqlite
```

For all services:

```bash
docker-compose up
```

Environment variables for database credentials are pre-configured with secure usernames and passwords.

---

## Usage Instructions

### Start All Databases

```bash
docker-compose up
```

### Start Specific Databases

Specify the services you want to run:

```bash
docker-compose up postgres mysql
```

### Stop All Databases

```bash
docker-compose down
```

### Restart Services

```bash
docker-compose restart
```

### Pull Latest Images

```bash
docker-compose pull
```

## Customization

- **Change Ports:** Adjust the `ports` section for each service.
- **Environment Variables:** Modify `POSTGRES_USER`, `MYSQL_PASSWORD`, `CASSANDRA_USER`, `AURORA_USER`, `SPANNER_USER`, etc., as needed.
- **Volumes:** Data persistence is managed via Docker volumes (e.g., `postgres-data`, `mysql-data`, `aurora-data`).

## Notes

- **Spanner Emulator:** Requires the [Google Cloud SDK](https://cloud.google.com/sdk) if you plan to interact with Spanner in production.
- **Aurora:** Uses MySQL-compatible drivers.
- **SQLite:** Uses a mounted volume at `./data` for database files.

## ❓ Troubleshooting

- **Port Conflicts:** Ensure ports like `5432`, `3306`, `9042`, `9010`, etc., aren't used by other processes.
- **Permission Issues:** Run `docker-compose` commands with `sudo` if necessary.
- **Database Connection Errors:** Check logs with `docker-compose logs <service-name>`.
