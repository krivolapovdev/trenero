package server

import (
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/krivolapovdev/trenerio/docs"
	"github.com/krivolapovdev/trenerio/internal/auth"
	"github.com/krivolapovdev/trenerio/internal/group"
	"github.com/krivolapovdev/trenerio/internal/lesson"
	"github.com/krivolapovdev/trenerio/internal/metric"
	"github.com/krivolapovdev/trenerio/internal/student"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/user"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

type Server struct {
	engine        *gin.Engine
	tokenProvider *security.TokenProvider

	authHandler    *auth.Handler
	userHandler    *user.Handler
	groupHandler   *group.Handler
	studentHandler *student.Handler
	lessonHandler  *lesson.Handler
	txHandler      *transaction.Handler
	metricHandler  *metric.Handler
}

func NewServer(
	tokenProvider *security.TokenProvider,
	allowedOrigins []string,
	authHandler *auth.Handler,
	userHandler *user.Handler,
	groupHandler *group.Handler,
	studentHandler *student.Handler,
	lessonHandler *lesson.Handler,
	txHandler *transaction.Handler,
	metricHandler *metric.Handler,
) *Server {
	engine := gin.New()

	s := &Server{
		engine:         engine,
		tokenProvider:  tokenProvider,
		authHandler:    authHandler,
		userHandler:    userHandler,
		groupHandler:   groupHandler,
		studentHandler: studentHandler,
		lessonHandler:  lessonHandler,
		txHandler:      txHandler,
		metricHandler:  metricHandler,
	}

	s.setupRoutes(allowedOrigins)

	return s
}

func (s *Server) setupRoutes(allowedOrigins []string) {
	s.engine.Use(RequestIDMiddleware())
	s.engine.Use(LoggingMiddleware())
	s.engine.Use(RecoveryMiddleware())
	s.engine.Use(CorsMiddleware(allowedOrigins))

	s.engine.NoRoute(func(c *gin.Context) {
		pkgerrors.RespondNotFound(c, "Endpoint not found")
	})

	s.engine.NoMethod(func(c *gin.Context) {
		pkgerrors.RespondProblem(c, http.StatusMethodNotAllowed, "Method Not Allowed", "Method not allowed")
	})

	s.engine.GET("/health", func(c *gin.Context) {
		c.String(http.StatusOK, "OK")
	})

	if gin.Mode() != gin.ReleaseMode {
		s.engine.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	}

	api := s.engine.Group("/api/v1")
	{
		jwtGroup := api.Group("/jwt")
		{
			jwtGroup.POST("/refresh", s.authHandler.RefreshTokens)
		}

		oauth2Group := api.Group("/oauth2")
		{
			oauth2Group.POST("/google", s.authHandler.GoogleLogin)
		}

		reviewerGroup := api.Group("/reviewer")
		{
			reviewerGroup.POST("/login", s.authHandler.ReviewerLogin)
		}

		authRequired := api.Group("")
		authRequired.Use(AuthMiddleware(s.tokenProvider))
		{
			userGroup := authRequired.Group("/users")
			{
				userGroup.DELETE("/me", s.userHandler.DeleteMyAccount)
			}

			groupGroup := authRequired.Group("/groups")
			{
				groupGroup.GET("", s.groupHandler.GetAllGroupsSummary)
				groupGroup.GET("/:groupId/students", s.groupHandler.GetGroupStudents)
				groupGroup.GET("/:groupId/lessons", s.groupHandler.GetGroupLessons)
				groupGroup.GET("/:groupId/report", s.groupHandler.GetGroupReport)
				groupGroup.POST("", s.groupHandler.CreateGroup)
				groupGroup.PATCH("/:groupId", s.groupHandler.UpdateGroup)
				groupGroup.DELETE("/:groupId", s.groupHandler.DeleteGroup)
			}

			studentGroup := authRequired.Group("/students")
			{
				studentGroup.GET("", s.studentHandler.GetAllStudentsSummary)
				studentGroup.GET("/overview", s.studentHandler.GetAllStudentsSummary)
				studentGroup.GET("/:studentId/visits", s.studentHandler.GetStudentVisits)
				studentGroup.GET("/:studentId/payments", s.studentHandler.GetStudentPayments)
				studentGroup.POST("", s.studentHandler.CreateStudent)
				studentGroup.POST("/:studentId/payments", s.studentHandler.CreateStudentPayment)
				studentGroup.PATCH("/:studentId", s.studentHandler.UpdateStudent)
				studentGroup.DELETE("/:studentId", s.studentHandler.DeleteStudent)
			}

			lessonGroup := authRequired.Group("/lessons")
			{
				lessonGroup.GET("/:lessonId/details", s.lessonHandler.GetLessonDetails)
				lessonGroup.POST("", s.lessonHandler.CreateLesson)
				lessonGroup.PATCH("/:lessonId", s.lessonHandler.UpdateLesson)
				lessonGroup.DELETE("/:lessonId", s.lessonHandler.DeleteLesson)
			}

			txGroup := authRequired.Group("/transactions")
			{
				txGroup.GET("", s.txHandler.GetPaginatedTransactions)
				txGroup.POST("", s.txHandler.CreateTransaction)
				txGroup.PATCH("/:transactionId", s.txHandler.UpdateTransaction)
				txGroup.DELETE("/:transactionId", s.txHandler.DeleteTransaction)
			}

			metricGroup := authRequired.Group("/metrics")
			{
				metricGroup.GET("/payments", s.metricHandler.GetPaymentStatistics)
			}
		}
	}
}

func (s *Server) Engine() *gin.Engine {
	return s.engine
}

func (s *Server) Run(addr string) error {
	return s.engine.Run(addr)
}
