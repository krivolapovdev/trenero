package student

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
	timeutil "github.com/krivolapovdev/trenerio/pkg/utils"
)

func ComputeStudentStatuses(
	student models.StudentResponse,
	visits []models.VisitResponse,
	payments []models.TransactionResponse,
	lessonsMap map[uuid.UUID]models.LessonResponse,
	today time.Time,
) []types.StudentStatus {
	return ComputeStudentStatusesWithVisitLessons(student, visits, payments, lessonsMap, lessonsMap, today)
}

func ComputeStudentStatusesWithVisitLessons(
	student models.StudentResponse,
	visits []models.VisitResponse,
	payments []models.TransactionResponse,
	lessonsMap map[uuid.UUID]models.LessonResponse,
	visitLessonsMap map[uuid.UUID]models.LessonResponse,
	today time.Time,
) []types.StudentStatus {
	if len(visits) == 0 && len(payments) == 0 {
		if student.Free {
			return []types.StudentStatus{types.StudentStatusFree}
		}
		return []types.StudentStatus{types.StudentStatusInactive}
	}

	statuses := make([]types.StudentStatus, 0)

	lastVisitLesson := findLatestLesson(visitLessonsMap)
	if lastVisitLesson != nil {
		for _, v := range visits {
			if v.LessonID == lastVisitLesson.ID {
				if v.Status == types.VisitStatusPresent {
					statuses = append(statuses, types.StudentStatusPresent)
				} else {
					statuses = append(statuses, types.StudentStatusMissing)
				}
				break
			}
		}
	}

	if student.Free {
		statuses = append(statuses, types.StudentStatusFree)
		return statuses
	}

	lastLesson := findLatestLesson(lessonsMap)

	referenceDate := today
	if lastLesson != nil {
		referenceDate = lastLesson.Date
	}

	maxPaidUntil := timeutil.MaxPaidUntil(payments)

	if timeutil.IsSubscriptionActive(maxPaidUntil, referenceDate) {
		statuses = append(statuses, types.StudentStatusPaid)
	} else {
		statuses = append(statuses, types.StudentStatusUnpaid)
	}

	return statuses
}
