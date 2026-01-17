CREATE SCHEMA IF NOT EXISTS visits_module;
CREATE SCHEMA IF NOT EXISTS groups_module;
CREATE SCHEMA IF NOT EXISTS lessons_module;
CREATE SCHEMA IF NOT EXISTS payments_module;
CREATE SCHEMA IF NOT EXISTS students_module;
CREATE SCHEMA IF NOT EXISTS users_module;


CREATE TABLE visits_module.visits
(
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    owner_id   uuid        NOT NULL,
    lesson_id  uuid        NOT NULL,
    student_id uuid        NOT NULL,
    present    boolean     NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz
);

ALTER TABLE visits_module.visits
    ADD CONSTRAINT visits_owner_lesson_student_unique UNIQUE (owner_id, lesson_id, student_id);

CREATE INDEX idx_visits_owner_deleted_created
    ON visits_module.visits (owner_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_visits_owner_student_deleted
    ON visits_module.visits (owner_id, student_id)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_visits_owner_lesson_deleted
    ON visits_module.visits (owner_id, lesson_id)
    WHERE deleted_at IS NULL;


CREATE TABLE groups_module.groups
(
    id            uuid PRIMARY KEY DEFAULT uuidv7(),
    owner_id      uuid         NOT NULL,
    name          VARCHAR(255) NOT NULL,
    default_price numeric(38, 2),
    note          VARCHAR(255),
    created_at    timestamptz  NOT NULL,
    updated_at    timestamptz  NOT NULL,
    deleted_at    timestamptz
);

ALTER TABLE groups_module.groups
    ADD CONSTRAINT groups_owner_id_name_unique UNIQUE (owner_id, name);

CREATE INDEX idx_groups_owner_not_deleted_name
    ON groups_module.groups (owner_id, name)
    WHERE deleted_at IS NULL;


CREATE TABLE lessons_module.lessons
(
    id              uuid PRIMARY KEY DEFAULT uuidv7(),
    owner_id        uuid        NOT NULL,
    group_id        uuid        NOT NULL,
    start_date_time timestamptz NOT NULL,
    created_at      timestamptz NOT NULL,
    updated_at      timestamptz NOT NULL,
    deleted_at      timestamptz
);

ALTER TABLE ONLY lessons_module.lessons
    ADD CONSTRAINT lessons_owner_id_group_id_start_date_time_unique UNIQUE (owner_id, group_id, start_date_time);

CREATE INDEX idx_lessons_owner_not_deleted_created
    ON lessons_module.lessons (owner_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_lessons_owner_group_created
    ON lessons_module.lessons (owner_id, group_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_lessons_owner_group_start
    ON lessons_module.lessons (owner_id, group_id, start_date_time DESC)
    WHERE deleted_at IS NULL;


CREATE TABLE payments_module.payments
(
    id                  uuid PRIMARY KEY DEFAULT uuidv7(),
    owner_id            uuid           NOT NULL,
    student_id          uuid           NOT NULL,
    amount              numeric(38, 2) NOT NULL,
    date                date           NOT NULL,
    lessons_per_payment integer        NOT NULL,
    created_at          timestamptz    NOT NULL,
    updated_at          timestamptz    NOT NULL,
    deleted_at          timestamptz
);

CREATE INDEX idx_payments_owner_not_deleted_created
    ON payments_module.payments (owner_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_payments_owner_student_not_deleted
    ON payments_module.payments (owner_id, student_id, created_at DESC)
    WHERE deleted_at IS NULL;


CREATE TABLE students_module.students
(
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    owner_id   uuid         NOT NULL,
    group_id   uuid,
    full_name  VARCHAR(255) NOT NULL,
    birthdate  date,
    phone      VARCHAR(15),
    note       VARCHAR(1023),
    created_at timestamptz  NOT NULL,
    updated_at timestamptz  NOT NULL,
    deleted_at timestamptz
);

ALTER TABLE students_module.students
    ADD CONSTRAINT students_owner_id_full_name_unique UNIQUE (owner_id, full_name);

CREATE INDEX idx_students_owner_not_deleted_full_name
    ON students_module.students (owner_id, full_name)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_students_owner_group_not_deleted_full_name
    ON students_module.students (owner_id, group_id, full_name)
    WHERE deleted_at IS NULL;


CREATE TYPE oauth2_provider AS ENUM ('GOOGLE', 'APPLE');

CREATE TABLE users_module.oauth2_users
(
    id          uuid PRIMARY KEY DEFAULT uuidv7(),
    provider    oauth2_provider NOT NULL,
    provider_id VARCHAR         NOT NULL,
    email       VARCHAR(255)    NOT NULL,
    created_at  timestamptz     NOT NULL,
    updated_at  timestamptz     NOT NULL,
    deleted_at  timestamptz
);

ALTER TABLE users_module.oauth2_users
    ADD CONSTRAINT users_provider_provider_id_unique UNIQUE (provider, provider_id);

CREATE UNIQUE INDEX idx_users_provider_provider_id_not_deleted
    ON users_module.oauth2_users (provider, provider_id)
    WHERE deleted_at IS NULL;
