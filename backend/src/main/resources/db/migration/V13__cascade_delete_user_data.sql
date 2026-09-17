DELETE FROM payments_module.transactions
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

DELETE FROM visits_module.visits
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

DELETE FROM lessons_module.lessons
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

DELETE FROM groups_module.group_students
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

DELETE FROM groups_module.groups
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

DELETE FROM students_module.students
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

DELETE FROM groups_module.group_students
WHERE group_id NOT IN (SELECT id FROM groups_module.groups);

ALTER TABLE groups_module.group_students
    ADD CONSTRAINT fk_group_students_group
        FOREIGN KEY (group_id)
            REFERENCES groups_module.groups (id)
            ON DELETE CASCADE;

ALTER TABLE students_module.students
    ADD CONSTRAINT fk_students_owner
        FOREIGN KEY (owner_id)
            REFERENCES users_module.oauth2_users (id)
            ON DELETE CASCADE;

ALTER TABLE groups_module.groups
    ADD CONSTRAINT fk_groups_owner
        FOREIGN KEY (owner_id)
            REFERENCES users_module.oauth2_users (id)
            ON DELETE CASCADE;

ALTER TABLE groups_module.group_students
    ADD CONSTRAINT fk_group_students_owner
        FOREIGN KEY (owner_id)
            REFERENCES users_module.oauth2_users (id)
            ON DELETE CASCADE;

ALTER TABLE lessons_module.lessons
    ADD CONSTRAINT fk_lessons_owner
        FOREIGN KEY (owner_id)
            REFERENCES users_module.oauth2_users (id)
            ON DELETE CASCADE;

ALTER TABLE visits_module.visits
    ADD CONSTRAINT fk_visits_owner
        FOREIGN KEY (owner_id)
            REFERENCES users_module.oauth2_users (id)
            ON DELETE CASCADE;

ALTER TABLE payments_module.transactions
    ADD CONSTRAINT fk_transactions_owner
        FOREIGN KEY (owner_id)
            REFERENCES users_module.oauth2_users (id)
            ON DELETE CASCADE;
