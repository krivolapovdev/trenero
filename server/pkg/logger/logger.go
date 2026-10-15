package logger

import (
	"context"
	"io"
	"log/slog"
	"os"
	"strings"
)

type contextKey string

const (
	requestIDKey contextKey = "request_id"
	userIDKey    contextKey = "user_id"
	loggerKey    contextKey = "logger"
)

type Config struct {
	Level  string
	Format string
	Output io.Writer
}

type contextHandler struct {
	slog.Handler
}

func (h *contextHandler) Handle(ctx context.Context, r slog.Record) error {
	if ctx != nil {
		if reqID, ok := ctx.Value(requestIDKey).(string); ok && reqID != "" {
			r.AddAttrs(slog.String("request_id", reqID))
		}
		if userID, ok := ctx.Value(userIDKey).(string); ok && userID != "" {
			r.AddAttrs(slog.String("user_id", userID))
		}
	}
	return h.Handler.Handle(ctx, r)
}

func (h *contextHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return &contextHandler{Handler: h.Handler.WithAttrs(attrs)}
}

func (h *contextHandler) WithGroup(name string) slog.Handler {
	return &contextHandler{Handler: h.Handler.WithGroup(name)}
}

func Init(cfgs ...Config) *slog.Logger {
	var cfg Config
	if len(cfgs) > 0 {
		cfg = cfgs[0]
	}

	if cfg.Level == "" {
		cfg.Level = os.Getenv("LOG_LEVEL")
	}
	if cfg.Format == "" {
		cfg.Format = os.Getenv("LOG_FORMAT")
		if cfg.Format == "" {
			env := strings.ToLower(os.Getenv("APP_ENV"))
			if env == "" {
				env = strings.ToLower(os.Getenv("ENV"))
			}
			if env == "prod" || env == "production" {
				cfg.Format = "json"
			} else {
				cfg.Format = "text"
			}
		}
	}
	if cfg.Output == nil {
		cfg.Output = os.Stdout
	}

	var level slog.Level
	switch strings.ToLower(strings.TrimSpace(cfg.Level)) {
	case "debug":
		level = slog.LevelDebug
	case "warn", "warning":
		level = slog.LevelWarn
	case "error":
		level = slog.LevelError
	default:
		level = slog.LevelInfo
	}

	opts := &slog.HandlerOptions{
		Level: level,
	}

	var baseHandler slog.Handler
	if strings.ToLower(strings.TrimSpace(cfg.Format)) == "json" {
		baseHandler = slog.NewJSONHandler(cfg.Output, opts)
	} else {
		baseHandler = slog.NewTextHandler(cfg.Output, opts)
	}

	handler := &contextHandler{Handler: baseHandler}
	l := slog.New(handler)
	slog.SetDefault(l)
	return l
}

func WithRequestID(ctx context.Context, requestID string) context.Context {
	return context.WithValue(ctx, requestIDKey, requestID)
}

func GetRequestID(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	if id, ok := ctx.Value(requestIDKey).(string); ok {
		return id
	}
	return ""
}

func WithUserID(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, userIDKey, userID)
}

func GetUserID(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	if id, ok := ctx.Value(userIDKey).(string); ok {
		return id
	}
	return ""
}

func WithLogger(ctx context.Context, l *slog.Logger) context.Context {
	return context.WithValue(ctx, loggerKey, l)
}

func FromContext(ctx context.Context) *slog.Logger {
	if ctx != nil {
		if l, ok := ctx.Value(loggerKey).(*slog.Logger); ok && l != nil {
			return l
		}
	}
	return slog.Default()
}

func Debug(msg string, args ...any) {
	slog.Default().Debug(msg, args...)
}

func Info(msg string, args ...any) {
	slog.Default().Info(msg, args...)
}

func Warn(msg string, args ...any) {
	slog.Default().Warn(msg, args...)
}

func Error(msg string, args ...any) {
	slog.Default().Error(msg, args...)
}

func DebugContext(ctx context.Context, msg string, args ...any) {
	FromContext(ctx).DebugContext(ctx, msg, args...)
}

func InfoContext(ctx context.Context, msg string, args ...any) {
	FromContext(ctx).InfoContext(ctx, msg, args...)
}

func WarnContext(ctx context.Context, msg string, args ...any) {
	FromContext(ctx).WarnContext(ctx, msg, args...)
}

func ErrorContext(ctx context.Context, msg string, args ...any) {
	FromContext(ctx).ErrorContext(ctx, msg, args...)
}
