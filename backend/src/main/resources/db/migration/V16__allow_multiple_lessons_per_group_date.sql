DROP INDEX IF EXISTS lessons_module.idx_unique_lesson_per_group_date;

CREATE INDEX idx_lessons_owner_group_date
ON lessons_module.lessons USING btree (owner_id, group_id, date);
