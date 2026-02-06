ALTER TABLE lessons_module.lessons
    ADD COLUMN date DATE;

UPDATE lessons_module.lessons
SET date = start_date_time::date;

ALTER TABLE lessons_module.lessons
    ALTER COLUMN date SET NOT NULL;

DROP INDEX lessons_module.idx_lessons_owner_group_start_unique_active;

ALTER TABLE lessons_module.lessons
    DROP COLUMN start_date_time;

CREATE UNIQUE INDEX idx_unique_lesson_per_group_date_active
    ON lessons_module.lessons (owner_id, group_id, date)
    WHERE deleted_at IS NULL;
