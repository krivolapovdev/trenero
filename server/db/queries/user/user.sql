-- name: GetUserByID :one
SELECT id, provider, provider_id, email, created_at, updated_at
FROM users_module.oauth2_users
WHERE id = $1;

-- name: GetUserByProviderAndProviderID :one
SELECT id, provider, provider_id, email, created_at, updated_at
FROM users_module.oauth2_users
WHERE provider = $1 AND provider_id = $2;

-- name: ExistsUserByID :one
SELECT EXISTS(
    SELECT 1 FROM users_module.oauth2_users WHERE id = $1
);

-- name: CreateUser :one
INSERT INTO users_module.oauth2_users (provider, provider_id, email)
VALUES ($1, $2, $3)
RETURNING id, provider, provider_id, email, created_at, updated_at;

-- name: DeleteUserByID :exec
DELETE FROM users_module.oauth2_users
WHERE id = $1;
