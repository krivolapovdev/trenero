DELETE
FROM users_module.oauth2_users
WHERE deleted_at IS NOT NULL;

DROP INDEX users_module.idx_users_provider_provider_id_unique_active;

ALTER TABLE users_module.oauth2_users
    ADD CONSTRAINT uq_users_provider_provider_id UNIQUE (provider, provider_id);

ALTER TABLE users_module.oauth2_users
    DROP COLUMN deleted_at;
