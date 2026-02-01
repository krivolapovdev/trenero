CREATE TYPE payments_module.transaction_type AS ENUM ('INCOME', 'EXPENSE');

CREATE TABLE payments_module.transactions
(
    id         UUID PRIMARY KEY DEFAULT uuidv7(),
    owner_id   UUID                             NOT NULL,
    type       payments_module.transaction_type NOT NULL,
    amount     DECIMAL(38, 2)                   NOT NULL,
    date       DATE                             NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE         NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE         NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE payments_module.student_payments
(
    transaction_id UUID PRIMARY KEY,
    student_id     UUID    NOT NULL,
    paid_lessons   INTEGER NOT NULL,
    CONSTRAINT fk_student_payment_transaction
        FOREIGN KEY (transaction_id)
            REFERENCES payments_module.transactions (id)
            ON DELETE CASCADE
);

WITH inserted_transactions AS (
    INSERT INTO payments_module.transactions
        (id, owner_id, type, amount, date, created_at, updated_at, deleted_at)
        SELECT id,
               owner_id,
               'INCOME'::payments_module.transaction_type,
               amount,
               date,
               created_at,
               updated_at,
               deleted_at
        FROM payments_module.payments
        RETURNING id)
INSERT
INTO payments_module.student_payments (transaction_id, student_id, paid_lessons)
SELECT p.id,
       p.student_id,
       p.paid_lessons
FROM payments_module.payments AS p
         JOIN inserted_transactions it ON p.id = it.id;
