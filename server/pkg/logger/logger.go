package logger

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"os"
	"strings"
	"sync"
)

type contextKey string

const (
	requestIDKey contextKey = "request_id"
	userIDKey    contextKey = "user_id"
	loggerKey    contextKey = "logger"
)

// ANSI color escape codes
const (
	colorReset   = "\033[0m"
	colorDim     = "\033[2m"
	colorBold    = "\033[1m"
	colorRed     = "\033[31m"
	colorGreen   = "\033[32m"
	colorYellow  = "\033[33m"
	colorCyan    = "\033[36m"
	colorMagenta = "\033[35m"
)

type Config struct {
	Level  string
	Format string
	Output io.Writer
}

// prettyHandler is a clean, readable, colorized slog Handler for development and terminal logs.
type prettyHandler struct {
	mu     sync.Mutex
	out    io.Writer
	level  slog.Level
	attrs  []slog.Attr
	groups []string
}

func (h *prettyHandler) Enabled(_ context.Context, l slog.Level) bool {
	return l >= h.level
}

func (h *prettyHandler) Handle(ctx context.Context, r slog.Record) error {
	h.mu.Lock()
	defer h.mu.Unlock()

	var levelStr string
	switch {
	case r.Level >= slog.LevelError:
		levelStr = colorRed + colorBold + "ERROR" + colorReset
	case r.Level >= slog.LevelWarn:
		levelStr = colorYellow + colorBold + "WARN " + colorReset
	case r.Level >= slog.LevelInfo:
		levelStr = colorGreen + "INFO " + colorReset
	default:
		levelStr = colorCyan + "DEBUG" + colorReset
	}

	timeStr := colorDim + r.Time.Format("15:04:05") + colorReset

	// Contextual metadata
	var meta string
	if ctx != nil {
		if reqID := GetRequestID(ctx); reqID != "" {
			meta += fmt.Sprintf(" %s[req:%s]%s", colorMagenta, reqID, colorReset)
		}
		if userID := GetUserID(ctx); userID != "" {
			meta += fmt.Sprintf(" %s[user:%s]%s", colorCyan, userID, colorReset)
		}
	}

	// Write prefix: timestamp LEVEL [meta] message
	line := fmt.Sprintf("%s %s%s %s%s%s", timeStr, levelStr, meta, colorBold, r.Message, colorReset)

	// Append handler-level attributes
	for _, a := range h.attrs {
		line += fmt.Sprintf(" %s%s=%v%s", colorCyan, a.Key, a.Value.Any(), colorReset)
	}

	// Append record attributes
	r.Attrs(func(a slog.Attr) bool {
		line += fmt.Sprintf(" %s%s=%v%s", colorCyan, a.Key, a.Value.Any(), colorReset)
		return true
	})

	line += "\n"
	_, err := io.WriteString(h.out, line)
	return err
}

func (h *prettyHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	newAttrs := make([]slog.Attr, 0, len(h.attrs)+len(attrs))
	newAttrs = append(newAttrs, h.attrs...)
	newAttrs = append(newAttrs, attrs...)
	return &prettyHandler{
		out:    h.out,
		level:  h.level,
		attrs:  newAttrs,
		groups: h.groups,
	}
}

func (h *prettyHandler) WithGroup(name string) slog.Handler {
	newGroups := append(slicesClone(h.groups), name)
	return &prettyHandler{
		out:    h.out,
		level:  h.level,
		attrs:  h.attrs,
		groups: newGroups,
	}
}

// contextJSONHandler injects request_id and user_id into standard slog.JSONHandler
type contextJSONHandler struct {
	slog.Handler
}

func (h *contextJSONHandler) Handle(ctx context.Context, r slog.Record) error {
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

func (h *contextJSONHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return &contextJSONHandler{Handler: h.Handler.WithAttrs(attrs)}
}

func (h *contextJSONHandler) WithGroup(name string) slog.Handler {
	return &contextJSONHandler{Handler: h.Handler.WithGroup(name)}
}

func slicesClone[T any](s []T) []T {
	if s == nil {
		return nil
	}
	c := make([]T, len(s))
	copy(c, s)
	return c
}

// Init initializes the default slog logger with colorized human-readable text output or JSON format.
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

	var handler slog.Handler
	if strings.ToLower(strings.TrimSpace(cfg.Format)) == "json" {
		handler = &contextJSONHandler{
			Handler: slog.NewJSONHandler(cfg.Output, &slog.HandlerOptions{Level: level}),
		}
	} else {
		handler = &prettyHandler{
			out:   cfg.Output,
			level: level,
		}
	}

	l := slog.New(handler)
	slog.SetDefault(l)
	return l
}

// Context utilities

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

// Top-level logging helpers

func Debug(msg string, args ...any) { slog.Default().Debug(msg, args...) }
func Info(msg string, args ...any)  { slog.Default().Info(msg, args...) }
func Warn(msg string, args ...any)  { slog.Default().Warn(msg, args...) }
func Error(msg string, args ...any) { slog.Default().Error(msg, args...) }

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
