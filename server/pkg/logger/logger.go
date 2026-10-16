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

func (h contextHandler) Handle(ctx context.Context, r slog.Record) error {
	if ctx != nil {
		if reqID := GetRequestID(ctx); reqID != "" {
			r.AddAttrs(slog.String("request_id", reqID))
		}
		if userID := GetUserID(ctx); userID != "" {
			r.AddAttrs(slog.String("user_id", userID))
		}
	}
	return h.Handler.Handle(ctx, r)
}

func (h contextHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return contextHandler{Handler: h.Handler.WithAttrs(attrs)}
}

func (h contextHandler) WithGroup(name string) slog.Handler {
	return contextHandler{Handler: h.Handler.WithGroup(name)}
}

func Init(cfgs ...Config) *slog.Logger {
	var cfg Config
	if len(cfgs) > 0 {
		cfg = cfgs[0]
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

	opts := &slog.HandlerOptions{Level: level}
	var baseHandler slog.Handler
	if strings.ToLower(strings.TrimSpace(cfg.Format)) == "json" {
		baseHandler = slog.NewJSONHandler(cfg.Output, opts)
	} else {
		baseHandler = slog.NewTextHandler(cfg.Output, opts)
	}

	l := slog.New(contextHandler{Handler: baseHandler})
	slog.SetDefault(l)
	return l
}

func WithRequestID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, requestIDKey, id)
}

func GetRequestID(ctx context.Context) string {
	if ctx != nil {
		if v, ok := ctx.Value(requestIDKey).(string); ok {
			return v
		}
	}
	return ""
}

func WithUserID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, userIDKey, id)
}

func GetUserID(ctx context.Context) string {
	if ctx != nil {
		if v, ok := ctx.Value(userIDKey).(string); ok {
			return v
		}
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

func Debug(msg string, args ...any) { slog.Debug(msg, args...) }
func Info(msg string, args ...any)  { slog.Info(msg, args...) }
func Warn(msg string, args ...any)  { slog.Warn(msg, args...) }
func Error(msg string, args ...any) { slog.Error(msg, args...) }

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
