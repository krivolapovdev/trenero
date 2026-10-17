package utils

import (
	"fmt"
	"strings"
	"time"

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

// TrimStringPtr returns a pointer to the trimmed string, or nil if the input pointer is nil.
func TrimStringPtr(s *string) *string {
	if s == nil {
		return nil
	}
	trimmed := strings.TrimSpace(*s)
	return &trimmed
}

// ValidateDateNotFuture ensures the date is in the present or past in UTC (not after time.Now().UTC()).
func ValidateDateNotFuture(d time.Time, fieldName string) error {
	if !d.IsZero() && d.UTC().After(time.Now().UTC()) {
		return pkgerrors.NewBadRequest(fmt.Sprintf("%s cannot be in the future", fieldName))
	}
	return nil
}
