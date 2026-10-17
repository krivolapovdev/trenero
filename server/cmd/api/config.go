package main

import (
	"fmt"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/krivolapovdev/trenerio/pkg/utils"
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
		Port:               utils.GetEnv("PORT", defaultPort),
		DBURL:              buildDatabaseURL(),
		JWTSecret:          utils.GetEnv("JWT_SECRET_KEY", defaultJWTSecret),
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
	if rawURL := os.Getenv("DB_URL"); rawURL != "" {
		return rawURL
	}

	user := utils.GetEnv("DB_USERNAME", defaultDBUser)
	pass := utils.GetEnv("DB_PASSWORD", defaultDBPassword)

	return fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", user, pass, defaultDBHost, defaultDBName)
}
