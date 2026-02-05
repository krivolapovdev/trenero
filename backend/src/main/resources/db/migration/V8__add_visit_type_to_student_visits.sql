ALTER TABLE visits_module.visits
    ALTER COLUMN status DROP DEFAULT;

CREATE TYPE visits_module.visit_type AS ENUM (
    'REGULAR',
    'FREE',
    'UNMARKED'
    );

ALTER TABLE visits_module.visits
    ADD COLUMN type visits_module.visit_type NOT NULL DEFAULT 'UNMARKED';

UPDATE visits_module.visits
SET type = CASE
               WHEN status::text IN ('PRESENT', 'ABSENT') THEN 'REGULAR'::visits_module.visit_type
               WHEN status::text = 'FREE' THEN 'FREE'::visits_module.visit_type
               ELSE 'UNMARKED'::visits_module.visit_type
    END
;

ALTER TYPE visits_module.visit_status RENAME TO visit_status_old;

CREATE TYPE visits_module.visit_status AS ENUM (
    'PRESENT',
    'ABSENT',
    'UNMARKED'
    );

ALTER TABLE visits_module.visits
    ALTER COLUMN status TYPE visits_module.visit_status
        USING (
        CASE
            WHEN status::text = 'FREE' THEN 'PRESENT'::visits_module.visit_status
            ELSE status::text::visits_module.visit_status
            END
        );

ALTER TABLE visits_module.visits
    ADD CONSTRAINT check_unmarked_consistency
        CHECK (
            (type = 'UNMARKED' AND status = 'UNMARKED')
                OR
            (type != 'UNMARKED' AND status != 'UNMARKED')
            );

DROP TYPE visits_module.visit_status_old;
