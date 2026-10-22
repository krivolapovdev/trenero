package group

import (
	"database/sql"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/stretchr/testify/assert"
)

func TestToGroupResponse(t *testing.T) {
	groupID := uuid.New()
	now := time.Now()
	priceStr := "150.50"
	expectedPrice := 150.50
	noteText := "Group notes"

	g := db.GroupsModuleGroup{
		ID:           groupID,
		Name:         "Swimming Group",
		DefaultPrice: sql.NullString{String: priceStr, Valid: true},
		Note:         sql.NullString{String: noteText, Valid: true},
		CreatedAt:    now,
	}

	resp := toGroupResponse(g)
	assert.Equal(t, groupID, resp.ID)
	assert.Equal(t, "Swimming Group", resp.Name)
	assert.NotNil(t, resp.DefaultPrice)
	assert.Equal(t, expectedPrice, *resp.DefaultPrice)
	assert.NotNil(t, resp.Note)
	assert.Equal(t, noteText, *resp.Note)
	assert.Equal(t, now, resp.CreatedAt)

	// Test with null fields
	gEmpty := db.GroupsModuleGroup{
		ID:        groupID,
		Name:      "Boxing Group",
		CreatedAt: now,
	}
	respEmpty := toGroupResponse(gEmpty)
	assert.Nil(t, respEmpty.DefaultPrice)
	assert.Nil(t, respEmpty.Note)
}
