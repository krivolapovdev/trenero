package logger

import (
	"bytes"
	"context"
	"log/slog"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestLogger_ContextValues(t *testing.T) {
	ctx := context.Background()

	assert.Empty(t, GetRequestID(nil))
	assert.Empty(t, GetRequestID(ctx))
	assert.Empty(t, GetUserID(nil))
	assert.Empty(t, GetUserID(ctx))

	reqID := "req-abc-123"
	ctxWithReq := WithRequestID(ctx, reqID)
	assert.Equal(t, reqID, GetRequestID(ctxWithReq))

	userID := "user-xyz-456"
	ctxWithUser := WithUserID(ctx, userID)
	assert.Equal(t, userID, GetUserID(ctxWithUser))

	ctxBoth := WithUserID(ctxWithReq, userID)
	assert.Equal(t, reqID, GetRequestID(ctxBoth))
	assert.Equal(t, userID, GetUserID(ctxBoth))
}

func TestLogger_FromContext(t *testing.T) {
	assert.Equal(t, slog.Default(), FromContext(nil))
	assert.Equal(t, slog.Default(), FromContext(context.Background()))

	customLogger := slog.New(slog.NewTextHandler(bytes.NewBuffer(nil), nil))
	ctx := WithLogger(context.Background(), customLogger)
	assert.Equal(t, customLogger, FromContext(ctx))
}

func TestLogger_Init(t *testing.T) {
	t.Run("DebugMode", func(t *testing.T) {
		gin.SetMode(gin.DebugMode)
		l := Init()
		assert.NotNil(t, l)
	})

	t.Run("ReleaseMode", func(t *testing.T) {
		gin.SetMode(gin.ReleaseMode)
		l := Init()
		assert.NotNil(t, l)
	})
}

func TestLogger_ContextHandler(t *testing.T) {
	buf := &bytes.Buffer{}
	innerHandler := slog.NewJSONHandler(buf, &slog.HandlerOptions{Level: slog.LevelDebug})
	handler := contextHandler{Handler: innerHandler}

	wrappedLogger := slog.New(handler)
	ctx := WithRequestID(context.Background(), "test-req-id")
	ctx = WithUserID(ctx, "test-user-id")

	wrappedLogger.InfoContext(ctx, "hello test message")

	output := buf.String()
	assert.Contains(t, output, `"request_id":"test-req-id"`)
	assert.Contains(t, output, `"user_id":"test-user-id"`)
	assert.Contains(t, output, `"msg":"hello test message"`)

	// Test WithAttrs & WithGroup
	hAttrs := handler.WithAttrs([]slog.Attr{slog.String("key", "val")})
	assert.NotNil(t, hAttrs)

	hGroup := handler.WithGroup("test_group")
	assert.NotNil(t, hGroup)
}

func TestLogger_GlobalAndContextLogFunctions(t *testing.T) {
	buf := &bytes.Buffer{}
	testHandler := slog.NewJSONHandler(buf, &slog.HandlerOptions{Level: slog.LevelDebug})
	l := slog.New(testHandler)

	ctx := WithLogger(context.Background(), l)

	DebugContext(ctx, "debug message", "foo", "bar")
	InfoContext(ctx, "info message", "foo", "bar")
	WarnContext(ctx, "warn message", "foo", "bar")
	ErrorContext(ctx, "error message", "foo", "bar")

	out := buf.String()
	assert.Contains(t, out, "debug message")
	assert.Contains(t, out, "info message")
	assert.Contains(t, out, "warn message")
	assert.Contains(t, out, "error message")

	// Global non-context functions
	Debug("direct debug")
	Info("direct info")
	Warn("direct warn")
	Error("direct error")
}
