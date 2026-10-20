-- name: FindAllVisitsByOwnerID :many
SELECT id, owner_id, lesson_id, student_id, status, type, created_at, updated_at
FROM visits_module.visits
WHERE owner_id = $1
ORDER BY created_at DESC;

-- name: FindVisitByIDAndOwnerID :one
SELECT id, owner_id, lesson_id, student_id, status, type, created_at, updated_at
FROM visits_module.visits
WHERE id = $1 AND owner_id = $2;

-- name: FindVisitsByLessonIDAndOwnerID :many
SELECT id, owner_id, lesson_id, student_id, status, type, created_at, updated_at
FROM visits_module.visits
WHERE lesson_id = $1 AND owner_id = $2;

-- name: FindVisitsByLessonIDsAndOwnerID :many
SELECT id, owner_id, lesson_id, student_id, status, type, created_at, updated_at
FROM visits_module.visits
WHERE owner_id = $1 AND lesson_id = ANY($2::uuid[])
ORDER BY created_at DESC;

-- name: FindVisitsByStudentIDAndOwnerID :many
SELECT id, owner_id, lesson_id, student_id, status, type, created_at, updated_at
FROM visits_module.visits
WHERE student_id = $1 AND owner_id = $2;

-- name: FindVisitsByStudentIDsAndOwnerID :many
SELECT id, owner_id, lesson_id, student_id, status, type, created_at, updated_at
FROM visits_module.visits
WHERE owner_id = $1 AND student_id = ANY($2::uuid[])
ORDER BY created_at DESC;

-- name: CreateVisit :one
INSERT INTO visits_module.visits (owner_id, lesson_id, student_id, status, type)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, owner_id, lesson_id, student_id, status, type, created_at, updated_at;

-- name: UpdateVisit :one
UPDATE visits_module.visits
SET status = $3,
    type = $4,
    updated_at = now()
WHERE id = $1 AND owner_id = $2
RETURNING id, owner_id, lesson_id, student_id, status, type, created_at, updated_at;

-- name: DeleteVisitByIDAndOwnerID :exec
DELETE FROM visits_module.visits
WHERE id = $1 AND owner_id = $2;

-- name: DeleteVisitsByLessonIDAndOwnerID :exec
DELETE FROM visits_module.visits
WHERE lesson_id = $1 AND owner_id = $2;

-- name: DeleteVisitsByLessonIDAndStudentIDsAndOwnerID :exec
DELETE FROM visits_module.visits
WHERE lesson_id = $1 AND owner_id = $2 AND student_id = ANY($3::uuid[]);

-- name: DeleteVisitsByStudentIDAndOwnerID :exec
DELETE FROM visits_module.visits
WHERE student_id = $1 AND owner_id = $2;

-- name: DeleteVisitsByOwnerID :exec
DELETE FROM visits_module.visits
WHERE owner_id = $1;
