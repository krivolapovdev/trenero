DELETE FROM visits_module.visits
WHERE status = 'UNMARKED'
   OR type = 'UNMARKED';

ALTER TABLE visits_module.visits
    DROP CONSTRAINT check_unmarked_consistency;

ALTER TABLE visits_module.visits
    ALTER COLUMN type DROP DEFAULT;

ALTER TYPE visits_module.visit_type RENAME TO visit_type_old;

CREATE TYPE visits_module.visit_type AS ENUM (
    'REGULAR',
    'FREE'
    );

ALTER TABLE visits_module.visits
    ALTER COLUMN type TYPE visits_module.visit_type
        USING (type::text::visits_module.visit_type);

DROP TYPE visits_module.visit_type_old;

ALTER TYPE visits_module.visit_status RENAME TO visit_status_old;

CREATE TYPE visits_module.visit_status AS ENUM (
    'PRESENT',
    'ABSENT',
    'EXCUSED'
    );

ALTER TABLE visits_module.visits
    ALTER COLUMN status TYPE visits_module.visit_status
        USING (status::text::visits_module.visit_status);

DROP TYPE visits_module.visit_status_old;
