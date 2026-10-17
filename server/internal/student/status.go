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

	var lastVisitLesson *models.LessonResponse
	for _, l := range visitLessonsMap {
		if lastVisitLesson == nil || l.Date.After(lastVisitLesson.Date) || (l.Date.Equal(lastVisitLesson.Date) && l.CreatedAt.After(lastVisitLesson.CreatedAt)) {
			cur := l
			lastVisitLesson = &cur
		}
	}

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

	var lastLesson *models.LessonResponse
	for _, l := range lessonsMap {
		if lastLesson == nil || l.Date.After(lastLesson.Date) || (l.Date.Equal(lastLesson.Date) && l.CreatedAt.After(lastLesson.CreatedAt)) {
			cur := l
			lastLesson = &cur
		}
	}

	referenceDate := today
	if lastLesson != nil {
		referenceDate = lastLesson.Date
	}

	var maxPaidUntil *time.Time
	for _, p := range payments {
		if p.PaymentDetails != nil {
			pu := p.PaymentDetails.PaidUntil
			if maxPaidUntil == nil || pu.After(*maxPaidUntil) {
				t := pu
				maxPaidUntil = &t
			}
		}
	}

	if timeutil.IsSubscriptionActive(maxPaidUntil, referenceDate) {
		statuses = append(statuses, types.StudentStatusPaid)
	} else {
		statuses = append(statuses, types.StudentStatusUnpaid)
	}

	return statuses
}
