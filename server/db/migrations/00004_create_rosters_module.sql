-- +goose Up
CREATE SCHEMA IF NOT EXISTS rosters_module;

CREATE TABLE rosters_module.rosters
(
    id       UUID DEFAULT uuidv7() PRIMARY KEY,
    owner_id UUID         NOT NULL REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE,
    name     VARCHAR(255) NOT NULL CHECK (name = trim(name) AND name != ''
) ,
    roster_date TIMESTAMPTZ,
    note        VARCHAR(255) CHECK (note = trim(note) AND note != ''),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE rosters_module.participants
(
    id         UUID                 DEFAULT uuidv7() PRIMARY KEY,
    roster_id  UUID        NOT NULL REFERENCES rosters_module.rosters (id) ON DELETE CASCADE,
    student_id UUID        NOT NULL REFERENCES students_module.students (id) ON DELETE CASCADE,
    note        VARCHAR(255) CHECK (note = trim(note) AND note != ''),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_rosters_updated_at
    BEFORE UPDATE
    ON rosters_module.rosters
    FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

CREATE TRIGGER trg_participants_updated_at
    BEFORE UPDATE
    ON rosters_module.participants
    FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

CREATE INDEX idx_rosters_owner_created ON rosters_module.rosters USING btree (owner_id, created_at DESC);
CREATE INDEX idx_participants_fast_lookup ON rosters_module.participants USING btree (roster_id, student_id);

-- +goose Down
DROP SCHEMA IF EXISTS rosters_module CASCADE;
