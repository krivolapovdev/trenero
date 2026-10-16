package main

import (
	"fmt"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

const (
	defaultPort               = "8080"
	defaultJWTSecret          = "your-jwt-ultra-secure-and-ultra-long-secret"
	defaultReviewerKey        = "your-reviewer-secret-key"
	defaultDBUser             = "username"
	defaultDBPassword         = "password"
	defaultDBHost             = "localhost:5432"
	defaultDBName             = "trenerio"
	defaultShutdownTimeout    = 10 * time.Second
	defaultAccessTokenExpiry  = 15 * time.Minute
	defaultRefreshTokenExpiry = 14 * 24 * time.Hour
)

type Config struct {
	Port               string
	DBURL              string
	JWTSecret          string
	ReviewerKey        string
	GoogleClientID     string
	AllowedOrigins     []string
	MigrationsDir      string
	AccessTokenExpiry  time.Duration
	RefreshTokenExpiry time.Duration
	ShutdownTimeout    time.Duration
}

func loadConfig() Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}

	jwtSecret := os.Getenv("JWT_SECRET_KEY")
	if jwtSecret == "" {
		jwtSecret = defaultJWTSecret
	}

	reviewerKey := os.Getenv("REVIEWER_SECRET_KEY")
	if reviewerKey == "" {
		reviewerKey = defaultReviewerKey
	}

	var allowedOrigins []string
	if gin.Mode() != gin.ReleaseMode {
		allowedOrigins = []string{"*"}
	} else {
		allowedOrigins = []string{"https://api.trenerio.ru"}
	}

	migrationsDir := "db/migrations"
	if _, err := os.Stat(migrationsDir); os.IsNotExist(err) {
		if _, err := os.Stat("server/" + migrationsDir); err == nil {
			migrationsDir = "server/" + migrationsDir
		}
	}

	return Config{
		Port:               port,
		DBURL:              buildDatabaseURL(),
		JWTSecret:          jwtSecret,
		ReviewerKey:        reviewerKey,
		GoogleClientID:     os.Getenv("GOOGLE_WEB_CLIENT_ID"),
		AllowedOrigins:     allowedOrigins,
		MigrationsDir:      migrationsDir,
		AccessTokenExpiry:  defaultAccessTokenExpiry,
		RefreshTokenExpiry: defaultRefreshTokenExpiry,
		ShutdownTimeout:    defaultShutdownTimeout,
	}
}

func buildDatabaseURL() string {
	user := os.Getenv("DB_USERNAME")
	if user == "" {
		user = defaultDBUser
	}

	pass := os.Getenv("DB_PASSWORD")
	if pass == "" {
		pass = defaultDBPassword
	}

	rawURL := os.Getenv("DB_URL")
	if rawURL == "" {
		return fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", user, pass, defaultDBHost, defaultDBName)
	}

	return rawURL
}
