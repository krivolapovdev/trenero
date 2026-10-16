package main

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"
	"github.com/pressly/goose/v3"

	"github.com/krivolapovdev/trenerio/pkg/logger"
)

func initDatabase(cfg Config) (*sql.DB, error) {
	dbConn, err := sql.Open("postgres", cfg.DBURL)
	if err != nil {
		return nil, fmt.Errorf("open database: %w", err)
	}

	dbConn.SetMaxOpenConns(25)
	dbConn.SetMaxIdleConns(25)
	dbConn.SetConnMaxLifetime(5 * time.Minute)

	pingCtx, pingCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer pingCancel()
	if err := dbConn.PingContext(pingCtx); err != nil {
		logger.Warn("unable to ping database", "error", err)
	}

	if err := goose.SetDialect("postgres"); err != nil {
		_ = dbConn.Close()
		return nil, fmt.Errorf("set goose dialect: %w", err)
	}

	if err := goose.Up(dbConn, cfg.MigrationsDir); err != nil {
		_ = dbConn.Close()
		return nil, fmt.Errorf("run goose migrations: %w", err)
	}

	logger.Info("database migrations applied successfully", "dir", cfg.MigrationsDir)
	return dbConn, nil
}
