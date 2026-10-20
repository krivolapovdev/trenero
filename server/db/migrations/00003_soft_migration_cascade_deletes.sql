-- +goose Up

-- 1. Find and delete useless / orphaned rows across modules

-- Delete visits where lesson does not exist
DELETE FROM visits_module.visits
WHERE lesson_id NOT IN (SELECT id FROM lessons_module.lessons);

-- Delete visits where student does not exist
DELETE FROM visits_module.visits
WHERE student_id NOT IN (SELECT id FROM students_module.students);

-- Delete visits where owner does not exist
DELETE FROM visits_module.visits
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

-- Delete visits for lessons belonging to non-existent groups
DELETE FROM visits_module.visits
WHERE lesson_id IN (
    SELECT id FROM lessons_module.lessons
    WHERE group_id IS NOT NULL AND group_id NOT IN (SELECT id FROM groups_module.groups)
);

-- Delete lessons where group does not exist
DELETE FROM lessons_module.lessons
WHERE group_id IS NOT NULL AND group_id NOT IN (SELECT id FROM groups_module.groups);

-- Delete visits for lessons belonging to non-existent users
DELETE FROM visits_module.visits
WHERE lesson_id IN (
    SELECT id FROM lessons_module.lessons
    WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users)
);

-- Delete lessons where owner does not exist
DELETE FROM lessons_module.lessons
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

-- Delete group_students where group does not exist
DELETE FROM groups_module.group_students
WHERE group_id NOT IN (SELECT id FROM groups_module.groups);

-- Delete group_students where student does not exist
DELETE FROM groups_module.group_students
WHERE student_id NOT IN (SELECT id FROM students_module.students);

-- Delete group_students where owner does not exist
DELETE FROM groups_module.group_students
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

-- Delete visits of lessons belonging to groups without a valid owner
DELETE FROM visits_module.visits
WHERE lesson_id IN (
    SELECT id FROM lessons_module.lessons
    WHERE group_id IN (SELECT id FROM groups_module.groups WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users))
);

-- Delete lessons belonging to groups without a valid owner
DELETE FROM lessons_module.lessons
WHERE group_id IN (SELECT id FROM groups_module.groups WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users));

-- Delete group_students belonging to groups without a valid owner
DELETE FROM groups_module.group_students
WHERE group_id IN (SELECT id FROM groups_module.groups WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users));

-- Delete groups where owner does not exist
DELETE FROM groups_module.groups
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

-- Delete student_payments where student does not exist
DELETE FROM payments_module.student_payments
WHERE student_id NOT IN (SELECT id FROM students_module.students);

-- Delete student_payments where transaction does not exist
DELETE FROM payments_module.student_payments
WHERE transaction_id NOT IN (SELECT id FROM payments_module.transactions);

-- Delete visits for students without a valid owner
DELETE FROM visits_module.visits
WHERE student_id IN (SELECT id FROM students_module.students WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users));

-- Delete group_students for students without a valid owner
DELETE FROM groups_module.group_students
WHERE student_id IN (SELECT id FROM students_module.students WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users));

-- Delete student_payments for students without a valid owner
DELETE FROM payments_module.student_payments
WHERE student_id IN (SELECT id FROM students_module.students WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users));

-- Delete students where owner does not exist
DELETE FROM students_module.students
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

-- Delete student_payments for transactions without a valid owner
DELETE FROM payments_module.student_payments
WHERE transaction_id IN (SELECT id FROM payments_module.transactions WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users));

-- Delete transactions where owner does not exist
DELETE FROM payments_module.transactions
WHERE owner_id NOT IN (SELECT id FROM users_module.oauth2_users);

-- 2. Add foreign key constraints with ON DELETE CASCADE

ALTER TABLE groups_module.groups
    ADD CONSTRAINT fk_groups_owner
    FOREIGN KEY (owner_id) REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE;

ALTER TABLE groups_module.group_students
    ADD CONSTRAINT fk_group_students_owner
    FOREIGN KEY (owner_id) REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE;

ALTER TABLE groups_module.group_students
    ADD CONSTRAINT fk_group_students_student
    FOREIGN KEY (student_id) REFERENCES students_module.students (id) ON DELETE CASCADE;

ALTER TABLE students_module.students
    ADD CONSTRAINT fk_students_owner
    FOREIGN KEY (owner_id) REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE;

ALTER TABLE lessons_module.lessons
    ADD CONSTRAINT fk_lessons_owner
    FOREIGN KEY (owner_id) REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE;

ALTER TABLE lessons_module.lessons
    ADD CONSTRAINT fk_lessons_group
    FOREIGN KEY (group_id) REFERENCES groups_module.groups (id) ON DELETE CASCADE;

ALTER TABLE visits_module.visits
    ADD CONSTRAINT fk_visits_owner
    FOREIGN KEY (owner_id) REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE;

ALTER TABLE visits_module.visits
    ADD CONSTRAINT fk_visits_lesson
    FOREIGN KEY (lesson_id) REFERENCES lessons_module.lessons (id) ON DELETE CASCADE;

ALTER TABLE visits_module.visits
    ADD CONSTRAINT fk_visits_student
    FOREIGN KEY (student_id) REFERENCES students_module.students (id) ON DELETE CASCADE;

ALTER TABLE payments_module.transactions
    ADD CONSTRAINT fk_transactions_owner
    FOREIGN KEY (owner_id) REFERENCES users_module.oauth2_users (id) ON DELETE CASCADE;

ALTER TABLE payments_module.student_payments
    ADD CONSTRAINT fk_student_payments_student
    FOREIGN KEY (student_id) REFERENCES students_module.students (id) ON DELETE CASCADE;

-- +goose Down
ALTER TABLE payments_module.student_payments DROP CONSTRAINT IF EXISTS fk_student_payments_student;
ALTER TABLE payments_module.transactions DROP CONSTRAINT IF EXISTS fk_transactions_owner;
ALTER TABLE visits_module.visits DROP CONSTRAINT IF EXISTS fk_visits_student;
ALTER TABLE visits_module.visits DROP CONSTRAINT IF EXISTS fk_visits_lesson;
ALTER TABLE visits_module.visits DROP CONSTRAINT IF EXISTS fk_visits_owner;
ALTER TABLE lessons_module.lessons DROP CONSTRAINT IF EXISTS fk_lessons_group;
ALTER TABLE lessons_module.lessons DROP CONSTRAINT IF EXISTS fk_lessons_owner;
ALTER TABLE students_module.students DROP CONSTRAINT IF EXISTS fk_students_owner;
ALTER TABLE groups_module.group_students DROP CONSTRAINT IF EXISTS fk_group_students_student;
ALTER TABLE groups_module.group_students DROP CONSTRAINT IF EXISTS fk_group_students_owner;
ALTER TABLE groups_module.groups DROP CONSTRAINT IF EXISTS fk_groups_owner;
