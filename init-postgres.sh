#!/bin/bash
set -e

# Create databases for each microservice
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Expense Service Database
    CREATE DATABASE fepa_expense;
    GRANT ALL PRIVILEGES ON DATABASE fepa_expense TO fepa;

    -- Budget Service Database
    CREATE DATABASE fepa_budget;
    GRANT ALL PRIVILEGES ON DATABASE fepa_budget TO fepa;

    -- Blog Service Database
    CREATE DATABASE fepa_blog;
    GRANT ALL PRIVILEGES ON DATABASE fepa_blog TO fepa;

    -- OCR Service Database
    CREATE DATABASE fepa_ocr;
    GRANT ALL PRIVILEGES ON DATABASE fepa_ocr TO fepa;

    -- AI Service Database
    CREATE DATABASE fepa_ai;
    GRANT ALL PRIVILEGES ON DATABASE fepa_ai TO fepa;

    -- List all databases
    \l
EOSQL

# Grant schema permissions for PostgreSQL 15+
for db in fepa_expense fepa_budget fepa_blog fepa_ocr fepa_ai; do
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" <<-EOSQL
        GRANT ALL ON SCHEMA public TO fepa;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fepa;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO fepa;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO fepa;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO fepa;
EOSQL
done

echo "✅ All PostgreSQL databases created successfully!"
