ALTER TABLE payments_module.student_payments
    ADD COLUMN paid_until DATE;

WITH ranked_daily AS (SELECT sp.transaction_id,
                             t.date AS tx_date,
                             ROW_NUMBER() OVER (
                                 PARTITION BY sp.student_id, t.date
                                 ORDER BY t.created_at, sp.transaction_id
                                 )  AS daily_offset
                      FROM payments_module.student_payments AS sp
                               JOIN payments_module.transactions t ON sp.transaction_id = t.id
                      WHERE t.deleted_at IS NULL)
UPDATE payments_module.student_payments AS sp
SET paid_until = (rd.tx_date + (rd.daily_offset * INTERVAL '1 month'))::date
FROM ranked_daily AS rd
WHERE sp.transaction_id = rd.transaction_id;

DELETE
FROM payments_module.student_payments
WHERE paid_until IS NULL;

ALTER TABLE payments_module.student_payments
    ALTER COLUMN paid_until SET NOT NULL;

ALTER TABLE payments_module.student_payments
    DROP COLUMN paid_lessons;

DROP INDEX payments_module.idx_student_payments_student_id;

CREATE UNIQUE INDEX idx_student_payments_student_paid_until_unique_active
    ON payments_module.student_payments (student_id, paid_until DESC);

DROP TABLE payments_module.payments;
