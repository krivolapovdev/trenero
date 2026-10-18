package main

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"

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
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

func wireServer(dbConn *sql.DB, cfg Config) *server.Server {
	queries := db.New(dbConn)
	tokenProvider := security.NewTokenProvider(
		cfg.JWTSecret,
		cfg.AccessTokenExpiry,
		cfg.RefreshTokenExpiry,
		cfg.ReviewerKey,
	)

	userService := user.NewService(queries)
	visitService := visit.NewService(queries, dbConn)
	authService := auth.NewService(
		userService.GetOrCreateUserFromOAuth2,
		userService.ExistsByID,
		tokenProvider,
		cfg.GoogleClientID,
	)

	var studentService *student.Service

	fetchStudentsByIDs := func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error) {
		return studentService.GetStudentsByIDs(ctx, studentIDs, ownerID)
	}

	fetchStudentByID := func(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error) {
		return studentService.GetStudentDetailsByID(ctx, studentID, ownerID)
	}

	computeStudentStatuses := func(
		st models.StudentResponse,
		visits []models.VisitResponse,
		payments []models.TransactionResponse,
		lessonsMap map[uuid.UUID]models.LessonResponse,
		groupLessonsMap map[uuid.UUID]models.LessonResponse,
		today time.Time,
	) []types.StudentStatus {
		return studentService.ComputeStudentStatuses(st, visits, payments, lessonsMap, groupLessonsMap, today)
	}

	txService := transaction.NewService(
		queries,
		dbConn,
		fetchStudentsByIDs,
		fetchStudentByID,
	)

	lessonService := lesson.NewService(
		queries,
		dbConn,
		visitService.GetVisitsByLessonID,
		fetchStudentsByIDs,
		visitService.CreateVisits,
		visitService.UpdateVisitsByLessonID,
		visitService.RemoveVisitsByLessonID,
	)

	groupService := group.NewService(
		queries,
		dbConn,
		fetchStudentsByIDs,
		computeStudentStatuses,
		visitService.GetVisitsByStudentIDs,
		visitService.GetVisitsByLessonIDs,
		txService.GetTransactionsByStudentIDs,
		lessonService.GetLessonsByGroupIDAndDateRange,
		lessonService.GetLessonsByIDs,
	)

	studentService = student.NewService(
		queries,
		dbConn,
		visitService.GetVisitsByStudentIDs,
		visitService.GetVisitsByStudentID,
		txService.GetTransactionsByStudentIDs,
		txService.GetTransactionsByStudentID,
		txService.CreateStudentPayment,
		groupService.GetGroupsByStudentIDs,
		groupService.SetStudentGroups,
		lessonService.GetLessonsByIDs,
	)

	metricService := metric.NewService(txService.GetTransactionsBetween)

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
