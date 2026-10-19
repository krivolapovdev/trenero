package types

import "github.com/google/uuid"

func ParseUUIDSlice(raw any) []uuid.UUID {
	if raw == nil {
		return nil
	}

	switch v := raw.(type) {
	case []uuid.UUID:
		return v
	case []string:
		ids := make([]uuid.UUID, 0, len(v))
		for _, str := range v {
			if id, err := uuid.Parse(str); err == nil {
				ids = append(ids, id)
			}
		}
		return ids
	case []any:
		ids := make([]uuid.UUID, 0, len(v))
		for _, item := range v {
			if str, ok := item.(string); ok {
				if id, err := uuid.Parse(str); err == nil {
					ids = append(ids, id)
				}
			}
		}
		return ids
	case string:
		if id, err := uuid.Parse(v); err == nil {
			return []uuid.UUID{id}
		}
	}

	return nil
}
