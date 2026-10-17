package utils

import (
	"strings"
	"testing"

	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
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
