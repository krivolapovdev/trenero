package types

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func TestParseUUIDSlice(t *testing.T) {
	// Nil input
	assert.Nil(t, ParseUUIDSlice(nil))

	// Already []uuid.UUID
	id1 := uuid.New()
	id2 := uuid.New()
	rawUUIDs := []uuid.UUID{id1, id2}
	assert.Equal(t, rawUUIDs, ParseUUIDSlice(rawUUIDs))

	// []string
	rawStrings := []string{id1.String(), id2.String(), "not-a-uuid"}
	expected := []uuid.UUID{id1, id2}
	assert.Equal(t, expected, ParseUUIDSlice(rawStrings))

	// []any (JSON unmarshaled slice)
	rawAny := []any{id1.String(), id2.String(), 12345}
	assert.Equal(t, expected, ParseUUIDSlice(rawAny))

	// Single string
	assert.Equal(t, []uuid.UUID{id1}, ParseUUIDSlice(id1.String()))

	// Single invalid string
	assert.Nil(t, ParseUUIDSlice("invalid-uuid"))

	// Unsupported type
	assert.Nil(t, ParseUUIDSlice(42))
}
