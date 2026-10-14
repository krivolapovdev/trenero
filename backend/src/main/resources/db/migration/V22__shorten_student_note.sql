UPDATE students_module.students
SET note = SUBSTRING(note FROM 1 FOR 255)
WHERE LENGTH(note) > 255;

ALTER TABLE students_module.students
    ALTER COLUMN note TYPE VARCHAR(255);
