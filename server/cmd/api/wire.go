package main

import (
	"database/sql"

	"github.com/krivolapovdev/trenerio/internal/auth"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/group"
	"github.com/krivolapovdev/trenerio/internal/lesson"
	"github.com/krivolapovdev/trenerio/internal/metric"
	"github.com/krivolapovdev/trenerio/internal/server"
	"github.com/krivolapovdev/trenerio/internal/student"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/user"
	"github.com/krivolapovdev/trenerio/internal/visit"
)

func wireServer(dbConn *sql.DB, cfg Config) *server.Server {
	queries := db.New(dbConn)
	tokenProvider := auth.NewTokenProvider(
		cfg.JWTSecret,
		cfg.AccessTokenExpiry,
		cfg.RefreshTokenExpiry,
		cfg.ReviewerKey,
	)

	userService := user.NewService(queries)
	visitService := visit.NewService(queries, dbConn)
	authService := auth.NewService(
		userService,
		tokenProvider,
		cfg.GoogleClientID,
	)

	studentService := student.NewService(queries, dbConn)

	txService := transaction.NewService(
		queries,
		dbConn,
		studentService,
	)

	lessonService := lesson.NewService(
		queries,
		dbConn,
		visitService,
		studentService,
	)

	groupService := group.NewService(
		queries,
		dbConn,
		studentService,
		visitService,
		txService,
		lessonService,
	)

	studentService.SetDependencies(
		visitService,
		txService,
		groupService,
		lessonService,
	)

	metricService := metric.NewService(txService)

	authHandler := auth.NewHandler(authService)
	userHandler := user.NewHandler(userService)
	groupHandler := group.NewHandler(groupService)
	studentHandler := student.NewHandler(studentService)
	lessonHandler := lesson.NewHandler(lessonService)
	txHandler := transaction.NewHandler(txService)
	metricHandler := metric.NewHandler(metricService)

	return server.NewServer(
		tokenProvider,
		cfg.AllowedOrigins,
		authHandler,
		userHandler,
		groupHandler,
		studentHandler,
		lessonHandler,
		txHandler,
		metricHandler,
	)
}
