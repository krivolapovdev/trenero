ALTER TABLE visits_module.visits
    DROP CONSTRAINT visits_owner_lesson_student_unique;

ALTER TABLE groups_module.groups
    DROP CONSTRAINT groups_owner_id_name_unique;

ALTER TABLE groups_module.group_students
    DROP CONSTRAINT group_students_unique;

ALTER TABLE lessons_module.lessons
    DROP CONSTRAINT lessons_owner_id_group_id_start_date_time_unique;

ALTER TABLE students_module.students
    DROP CONSTRAINT students_owner_id_full_name_unique;

ALTER TABLE users_module.oauth2_users
    DROP CONSTRAINT users_provider_provider_id_unique;


DROP INDEX groups_module.idx_groups_owner_not_deleted_name;

DROP INDEX groups_module.idx_group_students_active;

DROP INDEX students_module.idx_students_owner_not_deleted_full_name;

DROP INDEX users_module.idx_users_provider_provider_id_not_deleted;


CREATE UNIQUE INDEX idx_visits_owner_lesson_student_unique_active
    ON visits_module.visits (owner_id, lesson_id, student_id)
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX idx_groups_owner_name_unique_active
    ON groups_module.groups (owner_id, name)
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX idx_group_students_unique_active
    ON groups_module.group_students (owner_id, group_id, student_id)
    WHERE deleted_at IS NULL AND left_at IS NULL;

CREATE UNIQUE INDEX idx_lessons_owner_group_start_unique_active
    ON lessons_module.lessons (owner_id, group_id, start_date_time)
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX idx_students_owner_full_name_unique_active
    ON students_module.students (owner_id, full_name)
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX idx_users_provider_provider_id_unique_active
    ON users_module.oauth2_users (provider, provider_id)
    WHERE deleted_at IS NULL;


CREATE INDEX idx_transactions_owner_active_date
    ON payments_module.transactions (owner_id, date DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_transactions_owner_type_active
    ON payments_module.transactions (owner_id, type)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_student_payments_student_id
    ON payments_module.student_payments (student_id);
