package user

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestUserService_NewService(t *testing.T) {
	svc := NewService(nil, nil)
	require.NotNil(t, svc)
	assert.Nil(t, svc.db)
	assert.Nil(t, svc.sqlDB)
}
