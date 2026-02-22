CREATE OR REPLACE FUNCTION normalize_email_to_uppercase()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.email IS NOT NULL THEN
        NEW.email = UPPER(TRIM(NEW.email));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_email_uppercase
    BEFORE INSERT OR UPDATE
    ON users_module.oauth2_users
    FOR EACH ROW
EXECUTE FUNCTION normalize_email_to_uppercase();

UPDATE users_module.oauth2_users
SET email = UPPER(TRIM(email));
