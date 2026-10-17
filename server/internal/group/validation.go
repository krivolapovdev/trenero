package group

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/utils"
)

// validateStudentIDsExist verifies that all requested student IDs exist for the specified owner.
// If any IDs are missing, it returns a 400 Bad Request error.
func validateStudentIDsExist(
	ctx context.Context,
	fetchStudentsByIDs FetchStudentsByIDsFunc,
	studentIDs []uuid.UUID,
	ownerID uuid.UUID,
	action string,
) error {
	if len(studentIDs) == 0 || fetchStudentsByIDs == nil {
		return nil
	}

	stRows, err := fetchStudentsByIDs(ctx, studentIDs, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, fmt.Sprintf("Failed to fetch students by IDs for %s", action), "count", len(studentIDs), "error", err, "user_id", ownerID.String())
		return err
	}

	foundIDs := make([]uuid.UUID, 0, len(stRows))
	for _, sr := range stRows {
		foundIDs = append(foundIDs, sr.ID)
	}

	unknown := utils.FindMissingUUIDs(studentIDs, foundIDs)
	if len(unknown) > 0 {
		logger.WarnContext(ctx, fmt.Sprintf("Unknown student IDs provided for %s", action), "unknown", unknown, "user_id", ownerID.String())
		return pkgerrors.NewBadRequest(fmt.Sprintf("unknown students: %v", unknown))
	}

	return nil
}
