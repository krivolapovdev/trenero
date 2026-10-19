package validator

import (
	"strings"
	"testing"
	"time"

	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestValidateRequiredName(t *testing.T) {
	t.Run("BlankName_ReturnsBadRequest", func(t *testing.T) {
		_, err := ValidateRequiredName("   ", "name")
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "name must not be blank", badReq.Message)
	})

	t.Run("Exceeds255Chars_ReturnsBadRequest", func(t *testing.T) {
		longName := strings.Repeat("a", 256)
		_, err := ValidateRequiredName(longName, "fullName")
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "fullName must not exceed 255 characters", badReq.Message)
	})

	t.Run("ValidName_ReturnsTrimmed", func(t *testing.T) {
		val, err := ValidateRequiredName("  Group A  ", "name")
		require.NoError(t, err)
		assert.Equal(t, "Group A", val)
	})
}

func TestTrimStringPtr(t *testing.T) {
	t.Run("NilString_ReturnsNil", func(t *testing.T) {
		res := TrimStringPtr(nil)
		assert.Nil(t, res)
	})

	t.Run("WhitespaceString_ReturnsTrimmed", func(t *testing.T) {
		s := "   "
		res := TrimStringPtr(&s)
		require.NotNil(t, res)
		assert.Equal(t, "", *res)
	})

	t.Run("PaddedString_ReturnsTrimmed", func(t *testing.T) {
		s := "  note content  "
		res := TrimStringPtr(&s)
		require.NotNil(t, res)
		assert.Equal(t, "note content", *res)
	})
}

func TestValidateDateNotFuture(t *testing.T) {
	t.Run("ZeroDate_ReturnsNoError", func(t *testing.T) {
		err := ValidateDateNotFuture(time.Time{}, "date")
		assert.NoError(t, err)
	})

	t.Run("PastDate_ReturnsNoError", func(t *testing.T) {
		past := time.Now().UTC().Add(-24 * time.Hour)
		err := ValidateDateNotFuture(past, "date")
		assert.NoError(t, err)
	})

	t.Run("FutureDate_ReturnsBadRequest", func(t *testing.T) {
		future := time.Now().UTC().Add(24 * time.Hour)
		err := ValidateDateNotFuture(future, "date")
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "date cannot be in the future", badReq.Message)
	})
}
