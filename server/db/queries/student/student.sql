-- name: FindAllStudentsByOwnerID :many
SELECT id, owner_id, full_name, birthdate, phone, note, free, created_at, updated_at
FROM students_module.students
WHERE owner_id = $1
ORDER BY full_name ASC;

-- name: FindStudentByIDAndOwnerID :one
SELECT id, owner_id, full_name, birthdate, phone, note, free, created_at, updated_at
FROM students_module.students
WHERE id = $1 AND owner_id = $2;

-- name: FindStudentsByIDsAndOwnerID :many
SELECT id, owner_id, full_name, birthdate, phone, note, free, created_at, updated_at
FROM students_module.students
WHERE owner_id = $1 AND id = ANY($2::uuid[]);

-- name: ExistsStudentByOwnerIDAndFullName :one
SELECT EXISTS(
    SELECT 1 FROM students_module.students
    WHERE owner_id = $1 AND full_name = $2
);

-- name: ExistsStudentByOwnerIDAndFullNameAndIDNot :one
SELECT EXISTS(
    SELECT 1 FROM students_module.students
    WHERE owner_id = $1 AND full_name = $2 AND id != $3
);

-- name: CreateStudent :one
INSERT INTO students_module.students (owner_id, full_name, birthdate, phone, note, free)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id, owner_id, full_name, birthdate, phone, note, free, created_at, updated_at;

-- name: UpdateStudent :one
UPDATE students_module.students
SET full_name = $3,
    birthdate = $4,
    phone = $5,
    note = $6,
    free = $7
WHERE id = $1 AND owner_id = $2
RETURNING id, owner_id, full_name, birthdate, phone, note, free, created_at, updated_at;

-- name: DeleteStudentByIDAndOwnerID :exec
DELETE FROM students_module.students
WHERE id = $1 AND owner_id = $2;

-- name: DeleteStudentsByOwnerID :exec
DELETE FROM students_module.students
WHERE owner_id = $1;
