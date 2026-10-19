package utils

import "github.com/google/uuid"

// UniqueUUIDs preserves insertion order while deduplicating a slice of UUIDs.
func UniqueUUIDs(ids []uuid.UUID) []uuid.UUID {
	if len(ids) == 0 {
		return ids
	}
	seen := make(map[uuid.UUID]bool, len(ids))
	unique := make([]uuid.UUID, 0, len(ids))
	for _, id := range ids {
		if !seen[id] {
			seen[id] = true
			unique = append(unique, id)
		}
	}
	return unique
}

// FindMissingUUIDs returns all UUIDs in candidate that do not exist in existing.
func FindMissingUUIDs(candidate []uuid.UUID, existing []uuid.UUID) []uuid.UUID {
	foundMap := make(map[uuid.UUID]bool, len(existing))
	for _, id := range existing {
		foundMap[id] = true
	}
	missing := make([]uuid.UUID, 0)
	for _, id := range candidate {
		if !foundMap[id] {
			missing = append(missing, id)
		}
	}
	return missing
}

// DiffUUIDs compares current and requested UUID slices and returns which IDs need to be
// deleted (in current but not requested) and which need to be created (in requested but not current).
func DiffUUIDs(current, requested []uuid.UUID) (toDelete, toCreate []uuid.UUID) {
	reqMap := make(map[uuid.UUID]bool, len(requested))
	for _, id := range requested {
		reqMap[id] = true
	}

	curMap := make(map[uuid.UUID]bool, len(current))
	for _, id := range current {
		curMap[id] = true
		if !reqMap[id] {
			toDelete = append(toDelete, id)
		}
	}

	for _, id := range requested {
		if !curMap[id] {
			toCreate = append(toCreate, id)
		}
	}

	return toDelete, toCreate
}
