ALTER TABLE groups_module.group_students
    ADD COLUMN joined_at timestamptz;

UPDATE groups_module.group_students
SET joined_at = created_at
WHERE joined_at IS NULL;

ALTER TABLE groups_module.group_students
    ALTER COLUMN joined_at SET NOT NULL;
