package db

import (
	"context"
	"database/sql"
)

// WithTx executes a callback function inside a database transaction.
// If the callback returns an error or panics, the transaction is rolled back.
// Otherwise, the transaction is committed.
func WithTx(ctx context.Context, sqlDB *sql.DB, queries *Queries, fn func(qtx *Queries) error) (err error) {
	tx, err := sqlDB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback()
			panic(p)
		} else if err != nil {
			_ = tx.Rollback()
		}
	}()
	qtx := queries.WithTx(tx)
	if err = fn(qtx); err != nil {
		return err
	}
	return tx.Commit()
}
