-- +goose Up
ALTER TABLE students_module.students
    ALTER COLUMN phone TYPE VARCHAR(255);

-- +goose Down
UPDATE students_module.students
SET phone = CASE
    WHEN TRIM(LEFT(phone, 15)) = '' THEN NULL
    ELSE TRIM(LEFT(phone, 15))
END
WHERE phone IS NOT NULL AND LENGTH(phone) > 15;

ALTER TABLE students_module.students
    ALTER COLUMN phone TYPE VARCHAR(15);
