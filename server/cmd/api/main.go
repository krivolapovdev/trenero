package main

import (
	"context"
	"errors"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/krivolapovdev/trenerio/internal/server"
	"github.com/krivolapovdev/trenerio/pkg/logger"
)

// @title                       Trenerio API
// @version                     1.0
// @description                 Trenerio backend REST API
// @host                        localhost:8080
// @BasePath                    /
// @securityDefinitions.apikey  BearerAuth
// @in                          header
// @name                        Authorization
// @description                 Type "Bearer" followed by a space and JWT token.
func main() {
	logger.Init()

	cfg := loadConfig()

	dbConn, err := initDatabase(cfg)
	if err != nil {
		logger.Error("failed to initialize database", "error", err)
		os.Exit(1)
	}

	defer func() {
		if err := dbConn.Close(); err != nil {
			logger.Error("failed to close database connection", "error", err)
		}
	}()

	srv := wireServer(dbConn, cfg)

	runHTTPServer(srv, cfg)
}

func runHTTPServer(srv *server.Server, cfg Config) {
	httpServer := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           srv.Engine(),
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	go func() {
		logger.Info("Starting server", "port", cfg.Port, "allowed_origins", cfg.AllowedOrigins)
		if err := httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("server failed unexpectedly", "error", err)
			os.Exit(1)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("Shutting down server gracefully...")
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer shutdownCancel()

	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		logger.Error("Server forced to shutdown", "error", err)
		os.Exit(1)
	}

	logger.Info("Server exited gracefully")
}
