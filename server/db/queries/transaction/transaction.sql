-- name: FindAllTransactionsByOwnerID :many
SELECT id, owner_id, type, amount, date, created_at, updated_at
FROM payments_module.transactions
WHERE owner_id = $1
ORDER BY date DESC;

-- name: FindTransactionsByOwnerIDPaginated :many
SELECT 
    t.id, t.owner_id, t.type, t.amount, t.date, t.created_at, t.updated_at,
    sp.student_id, sp.paid_until
FROM payments_module.transactions t
LEFT JOIN payments_module.student_payments sp ON t.id = sp.transaction_id
WHERE t.owner_id = $1
ORDER BY t.date DESC, t.created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountTransactionsByOwnerID :one
SELECT COUNT(*)
FROM payments_module.transactions
WHERE owner_id = $1;

-- name: FindTransactionByIDAndOwnerID :one
SELECT 
    t.id, t.owner_id, t.type, t.amount, t.date, t.created_at, t.updated_at,
    sp.student_id, sp.paid_until
FROM payments_module.transactions t
LEFT JOIN payments_module.student_payments sp ON t.id = sp.transaction_id
WHERE t.id = $1 AND t.owner_id = $2;

-- name: FindTransactionsByOwnerIDAndDateBetween :many
SELECT 
    t.id, t.owner_id, t.type, t.amount, t.date, t.created_at, t.updated_at,
    sp.student_id, sp.paid_until
FROM payments_module.transactions t
LEFT JOIN payments_module.student_payments sp ON t.id = sp.transaction_id
WHERE t.owner_id = $1 AND t.date BETWEEN $2 AND $3
ORDER BY t.date DESC;

-- name: CreateTransaction :one
INSERT INTO payments_module.transactions (owner_id, type, amount, date)
VALUES ($1, $2, $3, $4)
RETURNING id, owner_id, type, amount, date, created_at, updated_at;

-- name: UpdateTransaction :one
UPDATE payments_module.transactions
SET amount = $3,
    date = $4,
    updated_at = now()
WHERE id = $1 AND owner_id = $2
RETURNING id, owner_id, type, amount, date, created_at, updated_at;

-- name: DeleteTransactionByIDAndOwnerID :exec
DELETE FROM payments_module.transactions
WHERE id = $1 AND owner_id = $2;

-- name: FindStudentPaymentsByOwnerID :many
SELECT sp.transaction_id, sp.student_id, sp.paid_until
FROM payments_module.student_payments sp
JOIN payments_module.transactions t ON sp.transaction_id = t.id
WHERE t.owner_id = $1
ORDER BY sp.paid_until DESC;

-- name: FindStudentPaymentByTransactionIDAndOwnerID :one
SELECT sp.transaction_id, sp.student_id, sp.paid_until
FROM payments_module.student_payments sp
JOIN payments_module.transactions t ON sp.transaction_id = t.id
WHERE sp.transaction_id = $1 AND t.owner_id = $2;

-- name: FindStudentPaymentsByStudentIDAndOwnerID :many
SELECT 
    t.id, t.owner_id, t.type, t.amount, t.date, t.created_at, t.updated_at,
    sp.student_id, sp.paid_until
FROM payments_module.student_payments sp
JOIN payments_module.transactions t ON sp.transaction_id = t.id
WHERE sp.student_id = $1 AND t.owner_id = $2
ORDER BY sp.paid_until DESC;

-- name: FindStudentPaymentsByStudentIDsAndOwnerID :many
SELECT 
    t.id, t.owner_id, t.type, t.amount, t.date, t.created_at, t.updated_at,
    sp.student_id, sp.paid_until
FROM payments_module.student_payments sp
JOIN payments_module.transactions t ON sp.transaction_id = t.id
WHERE t.owner_id = $1 AND sp.student_id = ANY($2::uuid[])
ORDER BY sp.paid_until DESC;

-- name: FindLatestPaidUntilByStudentID :one
SELECT sp.paid_until
FROM payments_module.student_payments sp
JOIN payments_module.transactions t ON sp.transaction_id = t.id
WHERE sp.student_id = $1 AND t.owner_id = $2
ORDER BY sp.paid_until DESC
LIMIT 1;

-- name: CreateStudentPayment :one
INSERT INTO payments_module.student_payments (transaction_id, student_id, paid_until)
VALUES ($1, $2, $3)
RETURNING transaction_id, student_id, paid_until;

-- name: UpdateStudentPayment :one
UPDATE payments_module.student_payments
SET paid_until = $2
WHERE transaction_id = $1
RETURNING transaction_id, student_id, paid_until;

-- name: DeleteStudentPaymentByTransactionID :exec
DELETE FROM payments_module.student_payments
WHERE transaction_id = $1;
