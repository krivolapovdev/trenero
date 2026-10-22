package roster

import (
	"context"
	"testing"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockStudentProvider struct {
	getStudentsByIDsFn func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error)
}

func (m *mockStudentProvider) GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	if m.getStudentsByIDsFn != nil {
		return m.getStudentsByIDsFn(ctx, studentIDs, ownerID)
	}
	return nil, nil
}

func TestRosterService_Validation(t *testing.T) {
	ctx := context.Background()
	ownerID := uuid.New()

	t.Run("CreateRoster_BlankName", func(t *testing.T) {
		svc := NewService(nil, nil, nil)
		_, err := svc.CreateRoster(ctx, request.CreateRosterRequest{
			Name: "   ",
		}, ownerID)
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "name must not be blank", badReq.Message)
	})

	t.Run("CreateRoster_StudentNotFound", func(t *testing.T) {
		missingID := uuid.New()
		studentProvider := &mockStudentProvider{
			getStudentsByIDsFn: func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error) {
				return []response.StudentResponse{}, nil // returns 0 students found
			},
		}

		svc := NewService(nil, nil, studentProvider)
		_, err := svc.CreateRoster(ctx, request.CreateRosterRequest{
			Name:       "Competition A",
			StudentIds: []uuid.UUID{missingID},
		}, ownerID)
		require.Error(t, err)
		var badReq *pkgerrors.BadRequestError
		require.ErrorAs(t, err, &badReq)
		assert.Equal(t, "One or more student IDs not found", badReq.Message)
	})
}
