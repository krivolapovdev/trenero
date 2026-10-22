-- name: FindAllRostersByOwnerID :many
SELECT id, owner_id, name, roster_date, note, created_at, updated_at
FROM rosters_module.rosters
WHERE owner_id = $1
ORDER BY created_at DESC;

-- name: FindRosterByIDAndOwnerID :one
SELECT id, owner_id, name, roster_date, note, created_at, updated_at
FROM rosters_module.rosters
WHERE id = $1 AND owner_id = $2;

-- name: CreateRoster :one
INSERT INTO rosters_module.rosters (owner_id, name, roster_date, note)
VALUES ($1, $2, $3, $4)
RETURNING id, owner_id, name, roster_date, note, created_at, updated_at;

-- name: UpdateRoster :one
UPDATE rosters_module.rosters
SET name = $3,
    roster_date = $4,
    note = $5
WHERE id = $1 AND owner_id = $2
RETURNING id, owner_id, name, roster_date, note, created_at, updated_at;

-- name: DeleteRosterByIDAndOwnerID :exec
DELETE FROM rosters_module.rosters
WHERE id = $1 AND owner_id = $2;

-- name: FindParticipantsByRosterIDAndOwnerID :many
SELECT p.id, p.roster_id, p.student_id, p.created_at, p.updated_at
FROM rosters_module.participants p
JOIN rosters_module.rosters r ON r.id = p.roster_id
WHERE p.roster_id = $1 AND r.owner_id = $2
ORDER BY p.created_at ASC;

-- name: FindParticipantsByOwnerID :many
SELECT p.id, p.roster_id, p.student_id, p.created_at, p.updated_at
FROM rosters_module.participants p
JOIN rosters_module.rosters r ON r.id = p.roster_id
WHERE r.owner_id = $1
ORDER BY p.created_at DESC;

-- name: CountParticipantsByRosterIDs :many
SELECT p.roster_id, COUNT(*) AS student_count
FROM rosters_module.participants p
JOIN rosters_module.rosters r ON r.id = p.roster_id
WHERE r.owner_id = $1 AND p.roster_id = ANY($2::uuid[])
GROUP BY p.roster_id;

-- name: CreateParticipant :one
INSERT INTO rosters_module.participants (roster_id, student_id)
VALUES ($1, $2)
RETURNING id, roster_id, student_id, created_at, updated_at;

-- name: DeleteParticipantsByRosterID :exec
DELETE FROM rosters_module.participants
WHERE roster_id = $1;

-- name: DeleteParticipantByStudentAndRosterID :exec
DELETE FROM rosters_module.participants
WHERE roster_id = $1 AND student_id = $2;

-- name: FindParticipantsByStudentIDAndOwnerID :many
SELECT p.id, p.roster_id, p.student_id, p.created_at, p.updated_at
FROM rosters_module.participants p
JOIN rosters_module.rosters r ON r.id = p.roster_id
WHERE p.student_id = $1 AND r.owner_id = $2;

-- name: ExistsParticipant :one
SELECT EXISTS(
    SELECT 1 FROM rosters_module.participants
    WHERE roster_id = $1 AND student_id = $2
);
