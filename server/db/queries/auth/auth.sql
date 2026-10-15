-- name: GetUserForAuth :one
SELECT id, email, provider, provider_id
FROM users_module.oauth2_users
WHERE provider = $1 AND provider_id = $2;
