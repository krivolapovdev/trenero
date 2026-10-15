package logger

import (
	"bytes"
	"context"
	"encoding/json"
	"log/slog"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestLoggerInitJSON(t *testing.T) {
	var buf bytes.Buffer
	l := Init(Config{
		Level:  "DEBUG",
		Format: "json",
		Output: &buf,
	})
	require.NotNil(t, l)

	Info("test message", "key", "value")

	var output map[string]interface{}
	err := json.Unmarshal(buf.Bytes(), &output)
	require.NoError(t, err)

	assert.Equal(t, "test message", output["msg"])
	assert.Equal(t, "INFO", output["level"])
	assert.Equal(t, "value", output["key"])
}

func TestLoggerInitText(t *testing.T) {
	var buf bytes.Buffer
	l := Init(Config{
		Level:  "INFO",
		Format: "text",
		Output: &buf,
	})
	require.NotNil(t, l)

	Info("hello world", "foo", "bar")
	assert.Contains(t, buf.String(), "hello world")
	assert.Contains(t, buf.String(), "foo=bar")
}

func TestLoggerContextValues(t *testing.T) {
	var buf bytes.Buffer
	Init(Config{
		Level:  "DEBUG",
		Format: "json",
		Output: &buf,
	})

	ctx := context.Background()
	ctx = WithRequestID(ctx, "req-12345")
	ctx = WithUserID(ctx, "user-67890")

	assert.Equal(t, "req-12345", GetRequestID(ctx))
	assert.Equal(t, "user-67890", GetUserID(ctx))

	InfoContext(ctx, "contextual log", "action", "testing")

	var output map[string]interface{}
	err := json.Unmarshal(buf.Bytes(), &output)
	require.NoError(t, err)

	assert.Equal(t, "contextual log", output["msg"])
	assert.Equal(t, "req-12345", output["request_id"])
	assert.Equal(t, "user-67890", output["user_id"])
	assert.Equal(t, "testing", output["action"])
}

func TestLoggerLevels(t *testing.T) {
	var buf bytes.Buffer
	Init(Config{
		Level:  "WARN",
		Format: "json",
		Output: &buf,
	})

	Debug("debug log")
	Info("info log")
	assert.Empty(t, buf.String())

	Warn("warn log")
	assert.Contains(t, buf.String(), "warn log")
	buf.Reset()

	Error("error log")
	assert.Contains(t, buf.String(), "error log")
}

func TestCustomLoggerInContext(t *testing.T) {
	var buf bytes.Buffer
	custom := slog.New(slog.NewJSONHandler(&buf, nil))
	ctx := WithLogger(context.Background(), custom)

	l := FromContext(ctx)
	assert.Equal(t, custom, l)

	InfoContext(ctx, "custom logger message")
	assert.Contains(t, buf.String(), "custom logger message")
}
