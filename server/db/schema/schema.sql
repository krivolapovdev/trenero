CREATE SCHEMA IF NOT EXISTS users_module;
CREATE SCHEMA IF NOT EXISTS groups_module;
CREATE SCHEMA IF NOT EXISTS students_module;
CREATE SCHEMA IF NOT EXISTS lessons_module;
CREATE SCHEMA IF NOT EXISTS payments_module;
CREATE SCHEMA IF NOT EXISTS visits_module;

CREATE TYPE users_module.oauth2_provider AS ENUM ('GOOGLE', 'APPLE');
CREATE TYPE visits_module.visit_status AS ENUM ('PRESENT', 'ABSENT', 'EXCUSED');
CREATE TYPE visits_module.visit_type AS ENUM ('REGULAR', 'FREE');
CREATE TYPE payments_module.transaction_type AS ENUM ('INCOME', 'EXPENSE');

CREATE TABLE users_module.oauth2_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider users_module.oauth2_provider NOT NULL,
    provider_id VARCHAR NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_users_provider_provider_id UNIQUE (provider, provider_id)
);

CREATE TABLE groups_module.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    default_price NUMERIC(38, 2),
    note VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT groups_owner_id_name_unique UNIQUE (owner_id, name)
);

CREATE INDEX idx_groups_owner_name_unique ON groups_module.groups USING btree (owner_id, name);

CREATE TABLE groups_module.group_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES groups_module.groups (id) ON DELETE CASCADE,
    student_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT group_students_unique UNIQUE (owner_id, group_id, student_id)
);

CREATE UNIQUE INDEX idx_group_students_unique ON groups_module.group_students USING btree (owner_id, group_id, student_id);

CREATE TABLE students_module.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    birthdate DATE,
    phone VARCHAR(15),
    note VARCHAR(255),
    free BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT students_owner_id_full_name_unique UNIQUE (owner_id, full_name)
);

CREATE UNIQUE INDEX idx_students_owner_full_name_unique ON students_module.students USING btree (owner_id, full_name);

CREATE TABLE lessons_module.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE,
    group_id UUID REFERENCES groups_module.groups (id) ON DELETE SET NULL,
    date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_lessons_owner_group_created ON lessons_module.lessons USING btree (owner_id, group_id, created_at DESC);
CREATE INDEX idx_lessons_owner_created ON lessons_module.lessons USING btree (owner_id, created_at DESC);
CREATE INDEX idx_lessons_owner_group_date ON lessons_module.lessons USING btree (owner_id, group_id, date);

CREATE TABLE visits_module.visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL,
    student_id UUID NOT NULL,
    status visits_module.visit_status NOT NULL,
    type visits_module.visit_type NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT visits_owner_lesson_student_unique UNIQUE (owner_id, lesson_id, student_id)
);

CREATE INDEX idx_visits_owner_created ON visits_module.visits USING btree (owner_id, created_at DESC);
CREATE INDEX idx_visits_owner_lesson ON visits_module.visits USING btree (owner_id, lesson_id);
CREATE UNIQUE INDEX idx_visits_owner_lesson_student_unique ON visits_module.visits USING btree (owner_id, lesson_id, student_id);
CREATE INDEX idx_visits_owner_student ON visits_module.visits USING btree (owner_id, student_id);

CREATE TABLE payments_module.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE,
    type payments_module.transaction_type NOT NULL,
    amount NUMERIC(38, 2) NOT NULL,
    date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_transactions_owner_date ON payments_module.transactions USING btree (owner_id, date DESC);
CREATE INDEX idx_transactions_owner_type ON payments_module.transactions USING btree (owner_id, type);

CREATE TABLE payments_module.student_payments (
    transaction_id UUID PRIMARY KEY REFERENCES payments_module.transactions (id) ON DELETE CASCADE,
    student_id UUID NOT NULL,
    paid_until TIMESTAMPTZ NOT NULL
);

CREATE UNIQUE INDEX idx_student_payments_student_paid_until_unique ON payments_module.student_payments USING btree (student_id, paid_until DESC);
