ALTER TABLE lessons_module.lessons
    ALTER COLUMN date TYPE timestamptz USING (date AT TIME ZONE 'UTC');

ALTER TABLE payments_module.transactions
    ALTER COLUMN date TYPE timestamptz USING (date AT TIME ZONE 'UTC');

ALTER TABLE payments_module.student_payments
    ALTER COLUMN paid_until TYPE timestamptz USING (paid_until AT TIME ZONE 'UTC');
