-- Habilitar a extensão para UUID (para geração automática de UUIDs)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Criar a tabela de usuários
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Criar índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Criar trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger apenas se ainda não existir
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

-- Criar o usuário admin com credenciais do ambiente
DO $$
DECLARE 
    admin_email TEXT;
    admin_password TEXT;
BEGIN
    -- Lendo as credenciais do ambiente configuradas pelo PostgreSQL
    SELECT current_setting('server.admin_user', true) INTO admin_email;
    SELECT current_setting('server.admin_password', true) INTO admin_password;

    -- Criando o usuário admin com senha segura (bcrypt)
    INSERT INTO users (name, email, password, phone, role)
    VALUES (
        admin_email, 
        admin_email, 
        crypt(admin_password, gen_salt('bf')),
        NULL,
        'admin'
    )
    ON CONFLICT (email) DO NOTHING;

    -- Removendo as variáveis de ambiente para segurança
    PERFORM set_config('server.admin_user', '', false);
    PERFORM set_config('server.admin_password', '', false);
END $$;
