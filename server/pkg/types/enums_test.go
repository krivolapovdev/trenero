package types

import (
	"encoding/json"
	"testing"
	"time"

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

func TestDate_JSON(t *testing.T) {
	t.Run("UnmarshalValidFormats", func(t *testing.T) {
		cases := []string{
			`"2000-01-15"`,
			`"2000-01-15T10:30:00Z"`,
			`"2000-01-15T10:30:00.000"`,
			`"2000-01-15T10:30:00"`,
			`"15.01.2000"`,
			`"2000/01/15"`,
		}

		for _, c := range cases {
			var d Date
			err := json.Unmarshal([]byte(c), &d)
			assert.NoError(t, err, "failed to unmarshal: %s", c)
			assert.Equal(t, 2000, d.Year())
			assert.Equal(t, time.January, d.Month())
			assert.Equal(t, 15, d.Day())
		}
	})

	t.Run("UnmarshalNullAndEmpty", func(t *testing.T) {
		var d1 Date
		err := json.Unmarshal([]byte(`null`), &d1)
		assert.NoError(t, err)
		assert.True(t, d1.IsZero())

		var d2 Date
		err = json.Unmarshal([]byte(`""`), &d2)
		assert.NoError(t, err)
		assert.True(t, d2.IsZero())
	})

	t.Run("UnmarshalInvalid", func(t *testing.T) {
		var d Date
		err := json.Unmarshal([]byte(`"not-a-date"`), &d)
		assert.Error(t, err)
	})

	t.Run("MarshalJSON", func(t *testing.T) {
		d := Date{Time: time.Date(1998, 6, 15, 0, 0, 0, 0, time.UTC)}
		b, err := json.Marshal(d)
		assert.NoError(t, err)
		assert.Equal(t, `"1998-06-15"`, string(b))

		dZero := Date{}
		bZero, err := json.Marshal(dZero)
		assert.NoError(t, err)
		assert.Equal(t, `null`, string(bZero))
	})
}
