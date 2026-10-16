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

	err := engine.SetTrustedProxies([]string{
		"10.0.0.0/8",
		"172.16.0.0/12",
		"192.168.0.0/16",
	})
	if err != nil {
		panic(err)
	}

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
	s.engine.Use(ErrorHandlerMiddleware())

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
		if s.authHandler != nil {
			s.authHandler.RegisterRoutes(api)
		}

		authRequired := api.Group("")
		authRequired.Use(AuthMiddleware(s.tokenProvider))
		{
			if s.userHandler != nil {
				s.userHandler.RegisterRoutes(authRequired)
			}
			if s.groupHandler != nil {
				s.groupHandler.RegisterRoutes(authRequired)
			}
			if s.studentHandler != nil {
				s.studentHandler.RegisterRoutes(authRequired)
			}
			if s.lessonHandler != nil {
				s.lessonHandler.RegisterRoutes(authRequired)
			}
			if s.txHandler != nil {
				s.txHandler.RegisterRoutes(authRequired)
			}
			if s.metricHandler != nil {
				s.metricHandler.RegisterRoutes(authRequired)
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
