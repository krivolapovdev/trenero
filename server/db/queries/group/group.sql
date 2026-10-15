-- name: FindAllGroupsByOwnerID :many
SELECT id, owner_id, name, default_price, note, created_at, updated_at
FROM groups_module.groups
WHERE owner_id = $1
ORDER BY name ASC;

-- name: FindGroupByIDAndOwnerID :one
SELECT id, owner_id, name, default_price, note, created_at, updated_at
FROM groups_module.groups
WHERE id = $1 AND owner_id = $2;

-- name: FindGroupsByIDsAndOwnerID :many
SELECT id, owner_id, name, default_price, note, created_at, updated_at
FROM groups_module.groups
WHERE owner_id = $1 AND id = ANY($2::uuid[]);

-- name: ExistsGroupByOwnerIDAndName :one
SELECT EXISTS(
    SELECT 1 FROM groups_module.groups
    WHERE owner_id = $1 AND name = $2
);

-- name: ExistsGroupByOwnerIDAndNameAndIDNot :one
SELECT EXISTS(
    SELECT 1 FROM groups_module.groups
    WHERE owner_id = $1 AND name = $2 AND id != $3
);

-- name: CreateGroup :one
INSERT INTO groups_module.groups (owner_id, name, default_price, note)
VALUES ($1, $2, $3, $4)
RETURNING id, owner_id, name, default_price, note, created_at, updated_at;

-- name: UpdateGroup :one
UPDATE groups_module.groups
SET name = $3,
    default_price = $4,
    note = $5,
    updated_at = now()
WHERE id = $1 AND owner_id = $2
RETURNING id, owner_id, name, default_price, note, created_at, updated_at;

-- name: DeleteGroupByIDAndOwnerID :exec
DELETE FROM groups_module.groups
WHERE id = $1 AND owner_id = $2;

-- name: FindGroupStudentsByOwnerID :many
SELECT id, owner_id, group_id, student_id, created_at, updated_at
FROM groups_module.group_students
WHERE owner_id = $1
ORDER BY created_at DESC;

-- name: FindGroupStudentsByGroupIDAndOwnerID :many
SELECT id, owner_id, group_id, student_id, created_at, updated_at
FROM groups_module.group_students
WHERE group_id = $1 AND owner_id = $2;

-- name: FindGroupStudentsByStudentIDAndOwnerID :many
SELECT id, owner_id, group_id, student_id, created_at, updated_at
FROM groups_module.group_students
WHERE student_id = $1 AND owner_id = $2;

-- name: FindGroupStudentsByStudentIDsAndOwnerID :many
SELECT id, owner_id, group_id, student_id, created_at, updated_at
FROM groups_module.group_students
WHERE owner_id = $1 AND student_id = ANY($2::uuid[]);

-- name: CountStudentsByGroupIDs :many
SELECT group_id, COUNT(*) AS student_count
FROM groups_module.group_students
WHERE owner_id = $1 AND group_id = ANY($2::uuid[])
GROUP BY group_id;

-- name: CreateGroupStudent :one
INSERT INTO groups_module.group_students (owner_id, group_id, student_id)
VALUES ($1, $2, $3)
RETURNING id, owner_id, group_id, student_id, created_at, updated_at;

-- name: DeleteGroupStudentsByGroupID :exec
DELETE FROM groups_module.group_students
WHERE group_id = $1 AND owner_id = $2;

-- name: DeleteGroupStudentByStudentAndGroupID :exec
DELETE FROM groups_module.group_students
WHERE group_id = $1 AND student_id = $2 AND owner_id = $3;
