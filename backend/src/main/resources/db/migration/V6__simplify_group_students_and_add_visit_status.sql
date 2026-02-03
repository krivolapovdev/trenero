DROP INDEX groups_module.idx_group_students_unique_active;

CREATE UNIQUE INDEX idx_group_students_unique_active
    ON groups_module.group_students (owner_id, group_id, student_id)
    WHERE deleted_at IS NULL;

ALTER TABLE groups_module.group_students
    DROP COLUMN joined_at;

ALTER TABLE groups_module.group_students
    DROP COLUMN left_at;

CREATE TYPE visits_module.visit_status AS ENUM (
    'PRESENT',
    'ABSENT',
    'UNMARKED',
    'FREE'
    );

ALTER TABLE visits_module.visits
    ADD COLUMN status visits_module.visit_status NOT NULL DEFAULT 'UNMARKED';

UPDATE visits_module.visits
SET status =
        CASE
            WHEN present THEN 'PRESENT'::visits_module.visit_status
            ELSE 'ABSENT'::visits_module.visit_status
            END;

ALTER TABLE visits_module.visits
    DROP COLUMN present;
