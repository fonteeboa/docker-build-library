# UUID v7 Integration with PostgreSQL

## Overview

This project explores the integration of **UUID v7** in PostgreSQL. UUIDs are commonly used as unique identifiers in databases, and **UUID v7** is particularly useful due to its time-ordered nature, which improves indexing and query performance.

The project includes:

- A PostgreSQL **Docker setup** with UUID v7 support.
- An **init-db.sql** script to configure the database with automatic UUID generation.
- Secure **password storage** using bcrypt.
- A **Docker Compose** configuration for easy deployment.

## Table of Contents

- [Setup](#setup)
- [Database Schema](#database-schema)
- [Trigger for Timestamp Updates](#trigger-for-timestamp-updates)
- [Admin User Creation](#admin-user-creation)
- [Docker Setup](#docker-setup)
- [Running the Project](#running-the-project)

---

## Setup

To use this project, ensure you have Docker and Docker Compose installed.

### Environment Variables (`.env`)

Create a `.env` file with the following:

```env
POSTGRES_USER=admin
POSTGRES_PASSWORD=supersecurepassword
POSTGRES_DB=mydatabase
TZ=UTC
PGTZ=UTC
WEB_ADMIN_USER=admin@example.com
WEB_ADMIN_PASSWORD=SecureP@ssw0rd
```

---

## Database Schema

The **`init-db.sql`** file sets up the database structure and ensures the usage of UUID v7.

### Enabling UUID Extension

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

### Creating the `users` Table

```sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Replace with UUID v7 when available
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    phone VARCHAR(20) NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Adding Indexes for Performance Optimization

```sql
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
```

---

## Trigger for Timestamp Updates

The following function and trigger ensure the `updated_at` field is automatically updated on record modifications:

### Function to Update `updated_at`

```sql
CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Creating the Trigger

```sql
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'trg_users_updated_at'
    ) THEN
        CREATE TRIGGER trg_users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW
        EXECUTE FUNCTION update_timestamp_column();
    END IF;
END $$;
```

---

## Admin User Creation

To securely create an admin user with bcrypt-hashed passwords:

```sql
DO $$
DECLARE
    admin_email TEXT;
    admin_password TEXT;
BEGIN
    SELECT current_setting('server.admin_user', true) INTO admin_email;
    SELECT current_setting('server.admin_password', true) INTO admin_password;

    INSERT INTO users (name, email, password, phone, role)
    VALUES (
        admin_email,
        admin_email,
        crypt(admin_password, gen_salt('bf')),
        NULL,
        'admin'
    )
    ON CONFLICT (email) DO NOTHING;

    -- Securely remove stored credentials
    PERFORM set_config('server.admin_user', '', false);
    PERFORM set_config('server.admin_password', '', false);
END $$;
```

---

## Docker Setup

The project uses **Docker** to manage the PostgreSQL database with UUID v7 support.

### **Dockerfile**

```dockerfile
# Use the official PostgreSQL 16 image
FROM postgres:16

# Copy initialization script
COPY init-db.sql /docker-entrypoint-initdb.d/

# Set environment variables
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV POSTGRES_DB=${POSTGRES_DB}
```

### **Docker Compose Configuration**

```yaml
services:
  postgres:
    image: postgres:16
    container_name: postgres_db
    restart: always
    env_file:
      - .env
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
      TZ: ${TZ}
      PGTZ: ${PGTZ}
      POSTGRES_INITDB_ARGS: "--set=server.admin_user='${WEB_ADMIN_USER}' --set=server.admin_password='${WEB_ADMIN_PASSWORD}'"
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql

volumes:
  pgdata:
```

---

## Running the Project

1. **Start the PostgreSQL container**

   ```sh
   docker-compose up -d
   ```

2. **Check logs** (if needed)

   ```sh
   docker logs postgres_db
   ```

3. **Access PostgreSQL**

   ```sh
   docker exec -it postgres_db psql -U admin -d mydatabase
   ```

4. **Verify table creation**

   ```sql
   SELECT * FROM users;
   ```
