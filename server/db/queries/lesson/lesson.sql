-- name: FindAllLessonsByGroupIDAndOwnerID :many
SELECT id, owner_id, group_id, date, created_at, updated_at
FROM lessons_module.lessons
WHERE group_id = $1 AND owner_id = $2
ORDER BY created_at DESC;

-- name: FindLessonByIDAndOwnerID :one
SELECT id, owner_id, group_id, date, created_at, updated_at
FROM lessons_module.lessons
WHERE id = $1 AND owner_id = $2;

-- name: FindLessonsByIDsAndOwnerID :many
SELECT id, owner_id, group_id, date, created_at, updated_at
FROM lessons_module.lessons
WHERE owner_id = $1 AND id = ANY($2::uuid[]);

-- name: FindLessonsByGroupIDAndDateBetween :many
SELECT id, owner_id, group_id, date, created_at, updated_at
FROM lessons_module.lessons
WHERE group_id = $1 AND owner_id = $2 AND date BETWEEN $3 AND $4
ORDER BY date ASC;

-- name: CreateLesson :one
INSERT INTO lessons_module.lessons (owner_id, group_id, date)
VALUES ($1, $2, $3)
RETURNING id, owner_id, group_id, date, created_at, updated_at;

-- name: UpdateLesson :one
UPDATE lessons_module.lessons
SET date = $3,
    updated_at = now()
WHERE id = $1 AND owner_id = $2
RETURNING id, owner_id, group_id, date, created_at, updated_at;

-- name: DeleteLessonByIDAndOwnerID :exec
DELETE FROM lessons_module.lessons
WHERE id = $1 AND owner_id = $2;
