CREATE TABLE groups_module.group_students
(
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    owner_id   uuid        NOT NULL,
    group_id   uuid        NOT NULL REFERENCES groups_module.groups (id),
    student_id uuid        NOT NULL,
    joined_at  timestamptz NOT NULL,
    left_at    timestamptz,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz,

    CONSTRAINT group_students_unique UNIQUE (group_id, student_id)
);

CREATE INDEX idx_group_students_active
    ON groups_module.group_students (group_id, student_id)
    WHERE deleted_at IS NULL;

INSERT INTO groups_module.group_students
(owner_id, group_id, student_id, joined_at, created_at, updated_at)
SELECT s.owner_id,
       s.group_id,
       s.id                                           AS student_id,
       COALESCE(MIN(l.start_date_time), s.created_at) AS joined_at,
       now()                                          AS created_at,
       now()                                          AS updated_at
FROM students_module.students AS s
         LEFT JOIN lessons_module.lessons AS l
                   ON l.group_id = s.group_id
                       AND l.deleted_at IS NULL
         LEFT JOIN visits_module.visits AS v
                   ON v.lesson_id = l.id
                       AND v.student_id = s.id
                       AND v.deleted_at IS NULL
WHERE s.group_id IS NOT NULL
GROUP BY s.id,
         s.owner_id,
         s.group_id,
         s.created_at;

ALTER TABLE students_module.students
    DROP COLUMN group_id;
