package utils

import (
	"fmt"
	"strings"

	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
)

// ValidateRequiredName trims the input name and ensures it is not blank and does not exceed 255 characters.
func ValidateRequiredName(name, fieldName string) (string, error) {
	trimmed := strings.TrimSpace(name)
	if trimmed == "" {
		return "", pkgerrors.NewBadRequest(fmt.Sprintf("%s must not be blank", fieldName))
	}
	if len(trimmed) > 255 {
		return "", pkgerrors.NewBadRequest(fmt.Sprintf("%s must not exceed 255 characters", fieldName))
	}
	return trimmed, nil
}
