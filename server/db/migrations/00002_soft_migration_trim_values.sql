-- +goose Up
UPDATE students_module.students
SET phone = TRIM(phone)
WHERE phone IS NOT NULL
  AND phone != TRIM(phone);

UPDATE students_module.students
SET note = TRIM(note)
WHERE note IS NOT NULL
  AND note != TRIM(note);

UPDATE groups_module.groups
SET note = TRIM(note)
WHERE note IS NOT NULL
  AND note != TRIM(note);

UPDATE users_module.oauth2_users
SET email = TRIM(email)
WHERE email != TRIM(email);

UPDATE students_module.students s
SET full_name = sub.new_name FROM (
    SELECT
        id,
        CASE
            WHEN row_number() OVER (
                PARTITION BY owner_id, TRIM(full_name)
                ORDER BY (full_name = TRIM(full_name)) DESC, created_at ASC, id ASC
            ) = 1 THEN TRIM(full_name)
            ELSE uuidv7()::text
        END AS new_name
    FROM students_module.students
) sub
WHERE s.id = sub.id
  AND s.full_name != sub.new_name;

UPDATE groups_module.groups g
SET name = sub.new_name FROM (
    SELECT
        id,
        CASE
            WHEN row_number() OVER (
                PARTITION BY owner_id, TRIM(name)
                ORDER BY (name = TRIM(name)) DESC, created_at ASC, id ASC
            ) = 1 THEN TRIM(name)
            ELSE uuidv7()::text
        END AS new_name
    FROM groups_module.groups
) sub
WHERE g.id = sub.id
  AND g.name != sub.new_name;

ALTER TABLE students_module.students
    ADD CONSTRAINT check_full_name_trimmed CHECK (full_name = TRIM(full_name));

ALTER TABLE students_module.students
    ADD CONSTRAINT check_phone_trimmed CHECK (phone = TRIM(phone));

ALTER TABLE students_module.students
    ADD CONSTRAINT check_note_trimmed CHECK (note = TRIM(note));

ALTER TABLE groups_module.groups
    ADD CONSTRAINT check_name_trimmed CHECK (name = TRIM(name));

ALTER TABLE groups_module.groups
    ADD CONSTRAINT check_note_trimmed CHECK (note = TRIM(note));

ALTER TABLE users_module.oauth2_users
    ADD CONSTRAINT check_email_trimmed CHECK (email = TRIM(email));

-- +goose Down
ALTER TABLE users_module.oauth2_users DROP CONSTRAINT IF EXISTS check_email_trimmed;
ALTER TABLE groups_module.groups DROP CONSTRAINT IF EXISTS check_note_trimmed;
ALTER TABLE groups_module.groups DROP CONSTRAINT IF EXISTS check_name_trimmed;
ALTER TABLE students_module.students DROP CONSTRAINT IF EXISTS check_note_trimmed;
ALTER TABLE students_module.students DROP CONSTRAINT IF EXISTS check_phone_trimmed;
ALTER TABLE students_module.students DROP CONSTRAINT IF EXISTS check_full_name_trimmed;
