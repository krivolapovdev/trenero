package visit

import (
	"github.com/krivolapovdev/trenerio/internal/db"
)

func toVisitResponse(v db.VisitsModuleVisit) VisitResponse {
	return VisitResponse{
		ID:        v.ID,
		Status:    VisitStatus(v.Status),
		Type:      VisitType(v.Type),
		LessonID:  v.LessonID,
		StudentID: v.StudentID,
		CreatedAt: v.CreatedAt,
	}
}
