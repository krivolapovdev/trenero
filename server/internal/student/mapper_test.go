package student

import (
	"database/sql"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/stretchr/testify/assert"
)

func TestToStudentResponse(t *testing.T) {
	studentID := uuid.New()
	now := time.Now()
	birthdate := time.Date(2010, 5, 12, 0, 0, 0, 0, time.UTC)
	phone := "+123456789"
	note := "Great student"

	s := db.StudentsModuleStudent{
		ID:        studentID,
		FullName:  "John Doe",
		Birthdate: sql.NullTime{Time: birthdate, Valid: true},
		Phone:     sql.NullString{String: phone, Valid: true},
		Note:      sql.NullString{String: note, Valid: true},
		CreatedAt: now,
		Free:      true,
	}

	resp := toStudentResponse(s)
	assert.Equal(t, studentID, resp.ID)
	assert.Equal(t, "John Doe", resp.FullName)
	assert.NotNil(t, resp.Birthdate)
	assert.Equal(t, birthdate, resp.Birthdate.Time)
	assert.NotNil(t, resp.Phone)
	assert.Equal(t, phone, *resp.Phone)
	assert.NotNil(t, resp.Note)
	assert.Equal(t, note, *resp.Note)
	assert.Equal(t, now, resp.CreatedAt)
	assert.True(t, resp.Free)

	// Test with null fields
	sEmpty := db.StudentsModuleStudent{
		ID:        studentID,
		FullName:  "Jane Doe",
		CreatedAt: now,
		Free:      false,
	}
	respEmpty := toStudentResponse(sEmpty)
	assert.Nil(t, respEmpty.Birthdate)
	assert.Nil(t, respEmpty.Phone)
	assert.Nil(t, respEmpty.Note)
	assert.False(t, respEmpty.Free)
}
