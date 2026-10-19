package group

import (
	"context"
	"github.com/krivolapovdev/trenerio/pkg/request"
	"testing"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestGroupService_DefaultPriceValidation(t *testing.T) {
	svc := NewService(nil, nil, nil, nil, nil, nil, nil, nil, nil)
	ctx := context.Background()
	ownerID := uuid.New()

	t.Run("CreateGroup_ZeroDefaultPrice", func(t *testing.T) {
		zero := 0.0
		_, err := svc.CreateGroup(ctx, request.CreateGroupRequest{
			Name:         "Swimming",
			DefaultPrice: &zero,
		}, ownerID)
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "defaultPrice must be greater than 0", badReq.Message)
	})

	t.Run("CreateGroup_NegativeDefaultPrice", func(t *testing.T) {
		neg := -50.0
		_, err := svc.CreateGroup(ctx, request.CreateGroupRequest{
			Name:         "Swimming",
			DefaultPrice: &neg,
		}, ownerID)
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "defaultPrice must be greater than 0", badReq.Message)
	})
}
