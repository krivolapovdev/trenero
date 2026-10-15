package types

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type samplePerson struct {
	Name      string `json:"name"`
	Birthdate *Date  `json:"birthdate,omitempty"`
}

func TestDate_MarshalJSON(t *testing.T) {
	d := Date{Time: time.Date(2026, 10, 15, 0, 0, 0, 0, time.UTC)}
	p := samplePerson{
		Name:      "Alex",
		Birthdate: &d,
	}

	bytes, err := json.Marshal(p)
	require.NoError(t, err)
	assert.JSONEq(t, `{"name":"Alex","birthdate":"2026-10-15"}`, string(bytes))

	emptyDate := Date{}
	bytes, err = json.Marshal(emptyDate)
	require.NoError(t, err)
	assert.Equal(t, "null", string(bytes))
}

func TestDate_UnmarshalJSON(t *testing.T) {
	jsonData := `{"name":"Sam","birthdate":"2026-10-15"}`
	var p samplePerson
	err := json.Unmarshal([]byte(jsonData), &p)
	require.NoError(t, err)
	require.NotNil(t, p.Birthdate)
	assert.Equal(t, 2026, p.Birthdate.Year())
	assert.Equal(t, time.Month(10), p.Birthdate.Month())
	assert.Equal(t, 15, p.Birthdate.Day())

	nullData := `{"name":"NoBirth","birthdate":null}`
	var p2 samplePerson
	err = json.Unmarshal([]byte(nullData), &p2)
	require.NoError(t, err)
	assert.Nil(t, p2.Birthdate)

	var d Date
	err = json.Unmarshal([]byte(`""`), &d)
	require.NoError(t, err)
	assert.True(t, d.IsZero())

	err = json.Unmarshal([]byte(`"not-a-date"`), &d)
	assert.Error(t, err)
}
