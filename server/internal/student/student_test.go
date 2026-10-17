package student

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestStudentService_DateValidation(t *testing.T) {
	svc := NewService(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
	ctx := context.Background()
	ownerID := uuid.New()

	t.Run("CreateStudent_FutureBirthdate", func(t *testing.T) {
		futureBirthdate := types.Date{Time: time.Now().UTC().Add(24 * time.Hour)}
		_, err := svc.CreateStudent(ctx, models.CreateStudentRequest{
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
		_, err := svc.CreateStudentPayment(ctx, uuid.New(), ownerID, models.CreateStudentPaymentRequest{
			Amount:    1000,
			Date:      futureDate,
			PaidUntil: futureDate.Add(24 * time.Hour),
		})
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "date cannot be in the future", badReq.Message)
	})
}
