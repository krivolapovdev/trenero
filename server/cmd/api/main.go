package main

import (
	"database/sql"
	"fmt"
	"os"
	"strings"
	"time"

	_ "github.com/lib/pq"
	"github.com/pressly/goose/v3"

	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/server"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

func main() {
	logger.Init()

	port := os.Getenv("PORT")
	if port == "" {
		port = os.Getenv("SERVER_PORT")
	}
	if port == "" {
		port = "8080"
	}

	dbURL := buildDatabaseURL()

	jwtSecret := os.Getenv("JWT_SECRET_KEY")
	if jwtSecret == "" {
		jwtSecret = "your-jwt-ultra-secure-and-ultra-long-secret"
	}

	reviewerKey := os.Getenv("REVIEWER_SECRET_KEY")
	if reviewerKey == "" {
		reviewerKey = "your-reviewer-secret-key"
	}

	googleClientID := os.Getenv("GOOGLE_WEB_CLIENT_ID")

	corsOrigins := os.Getenv("CORS_ALLOWED_ORIGINS")
	var allowedOrigins []string
	if corsOrigins != "" {
		for _, o := range strings.Split(corsOrigins, ",") {
			o = strings.TrimSpace(o)
			if o != "" {
				allowedOrigins = append(allowedOrigins, o)
			}
		}
	} else {
		allowedOrigins = []string{"*"}
	}

	migrationsDir := os.Getenv("MIGRATIONS_DIR")
	if migrationsDir == "" {
		migrationsDir = "db/migrations"
	}
	if _, err := os.Stat(migrationsDir); os.IsNotExist(err) {
		if _, err := os.Stat("server/" + migrationsDir); err == nil {
			migrationsDir = "server/" + migrationsDir
		}
	}

	dbConn, err := sql.Open("postgres", dbURL)
	if err != nil {
		logger.Error("failed to open database connection", "error", err)
		os.Exit(1)
	}
	defer dbConn.Close()

	if err := dbConn.Ping(); err != nil {
		logger.Warn("unable to ping database", "error", err)
	}

	if err := goose.SetDialect("postgres"); err != nil {
		logger.Error("failed to set goose dialect", "error", err)
		os.Exit(1)
	}

	if err := goose.Up(dbConn, migrationsDir); err != nil {
		logger.Error("goose migrations failed", "error", err)
		os.Exit(1)
	} else {
		logger.Info("database migrations applied successfully", "dir", migrationsDir)
	}

	queries := db.New(dbConn)
	tokenProvider := security.NewTokenProvider(jwtSecret, 15*time.Minute, 14*24*time.Hour, reviewerKey)
	srv := server.NewServer(dbConn, queries, tokenProvider, googleClientID, allowedOrigins)

	logger.Info("Starting server", "port", port, "allowed_origins", allowedOrigins)
	if err := srv.Run(":" + port); err != nil {
		logger.Error("failed to start server", "error", err)
		os.Exit(1)
	}
}

func buildDatabaseURL() string {
	user := os.Getenv("DB_USERNAME")
	if user == "" {
		user = "username"
	}

	pass := os.Getenv("DB_PASSWORD")
	if pass == "" {
		pass = "password"
	}

	rawURL := os.Getenv("DB_URL")
	if rawURL == "" {
		return fmt.Sprintf("postgres://%s:%s@localhost:5432/trenerio?sslmode=disable", user, pass)
	}

	return rawURL
}
