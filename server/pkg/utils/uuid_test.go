package utils

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func TestUniqueUUIDs(t *testing.T) {
	t.Run("EmptyOrNil", func(t *testing.T) {
		assert.Nil(t, UniqueUUIDs(nil))
		assert.Empty(t, UniqueUUIDs([]uuid.UUID{}))
	})

	t.Run("DeduplicatesWhilePreservingOrder", func(t *testing.T) {
		id1, id2, id3 := uuid.New(), uuid.New(), uuid.New()
		input := []uuid.UUID{id1, id2, id1, id3, id2, id3}
		expected := []uuid.UUID{id1, id2, id3}
		assert.Equal(t, expected, UniqueUUIDs(input))
	})
}

func TestFindMissingUUIDs(t *testing.T) {
	id1, id2, id3 := uuid.New(), uuid.New(), uuid.New()

	t.Run("NoMissing", func(t *testing.T) {
		missing := FindMissingUUIDs([]uuid.UUID{id1, id2}, []uuid.UUID{id2, id1, id3})
		assert.Empty(t, missing)
	})

	t.Run("SomeMissing", func(t *testing.T) {
		missing := FindMissingUUIDs([]uuid.UUID{id1, id2, id3}, []uuid.UUID{id2})
		assert.Equal(t, []uuid.UUID{id1, id3}, missing)
	})
}

func TestDiffUUIDs(t *testing.T) {
	id1, id2, id3, id4 := uuid.New(), uuid.New(), uuid.New(), uuid.New()

	current := []uuid.UUID{id1, id2}
	requested := []uuid.UUID{id2, id3, id4}

	toDelete, toCreate := DiffUUIDs(current, requested)
	assert.Equal(t, []uuid.UUID{id1}, toDelete)
	assert.Equal(t, []uuid.UUID{id3, id4}, toCreate)
}
