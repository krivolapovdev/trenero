package student

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestStudentService_DateValidation(t *testing.T) {
	svc := NewService(nil, nil)
	ctx := context.Background()
	ownerID := uuid.New()

	t.Run("CreateStudent_FutureBirthdate", func(t *testing.T) {
		futureBirthdate := types.Date{Time: time.Now().UTC().Add(24 * time.Hour)}
		_, err := svc.CreateStudent(ctx, request.CreateStudentRequest{
			FullName:  "Test Student",
			Birthdate: &futureBirthdate,
		}, ownerID)
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "birthdate cannot be in the future", badReq.Message)
	})

	t.Run("CreateStudentPayment_FutureDate", func(t *testing.T) {
		futureDate := time.Now().UTC().Add(24 * time.Hour)
		_, err := svc.CreateStudentPayment(ctx, uuid.New(), ownerID, request.CreateStudentPaymentRequest{
			Amount:    1000,
			Date:      futureDate,
			PaidUntil: futureDate.Add(24 * time.Hour),
		})
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "date cannot be in the future", badReq.Message)
	})

	t.Run("GetTransactionStudentsByIDs_Empty", func(t *testing.T) {
		res, err := svc.GetTransactionStudentsByIDs(ctx, []uuid.UUID{}, ownerID)
		require.NoError(t, err)
		assert.Empty(t, res)
	})
}

func TestStudentService_Dependencies(t *testing.T) {
	svc := NewService(nil, nil)
	require.NotNil(t, svc)

	svc.SetDependencies(nil, nil, nil, nil)
	assert.Nil(t, svc.visitProvider)

	svcWithDeps := NewServiceWithDependencies(nil, nil, nil, nil, nil, nil)
	require.NotNil(t, svcWithDeps)
}
