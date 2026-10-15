package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	_ "github.com/lib/pq"
	"github.com/pressly/goose/v3"

	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/server"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

func main() {
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
		log.Fatalf("failed to open database connection: %v", err)
	}
	defer dbConn.Close()

	if err := dbConn.Ping(); err != nil {
		log.Printf("warning: unable to ping database: %v", err)
	}

	if err := goose.SetDialect("postgres"); err != nil {
		log.Fatalf("failed to set goose dialect: %v", err)
	}

	if err := goose.Up(dbConn, migrationsDir); err != nil {
		log.Printf("warning: goose migrations failed: %v", err)
	}

	queries := db.New(dbConn)
	tokenProvider := security.NewTokenProvider(jwtSecret, 15*time.Minute, 14*24*time.Hour, reviewerKey)
	srv := server.NewServer(dbConn, queries, tokenProvider, googleClientID, allowedOrigins)

	log.Printf("Starting server on port %s", port)
	if err := srv.Run(":" + port); err != nil {
		log.Fatalf("failed to start server: %v", err)
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
		return fmt.Sprintf("postgres://%s:%s@localhost:5432/trenero?sslmode=disable", user, pass)
	}

	return rawURL
}
