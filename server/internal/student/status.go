package student

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/lesson"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/visit"
)

func ComputeStudentStatuses(
	student response.StudentResponse,
	visits []visit.VisitResponse,
	payments []transaction.TransactionResponse,
	lessonsMap map[uuid.UUID]response.LessonResponse,
	today time.Time,
) []StudentStatus {
	return ComputeStudentStatusesWithVisitLessons(student, visits, payments, lessonsMap, lessonsMap, today)
}

func ComputeStudentStatusesWithVisitLessons(
	student response.StudentResponse,
	visits []visit.VisitResponse,
	payments []transaction.TransactionResponse,
	lessonsMap map[uuid.UUID]response.LessonResponse,
	visitLessonsMap map[uuid.UUID]response.LessonResponse,
	today time.Time,
) []StudentStatus {
	if len(visits) == 0 && len(payments) == 0 {
		if student.Free {
			return []StudentStatus{StudentStatusFree}
		}
		return []StudentStatus{StudentStatusInactive}
	}

	statuses := make([]StudentStatus, 0)

	studentVisitLessons := make(map[uuid.UUID]response.LessonResponse)
	for _, v := range visits {
		if l, ok := visitLessonsMap[v.LessonID]; ok {
			studentVisitLessons[v.LessonID] = l
		}
	}

	lastVisitLesson := lesson.FindLatestLesson(studentVisitLessons)
	if lastVisitLesson != nil {
		if v := visit.FindVisitByLessonID(visits, lastVisitLesson.ID); v != nil {
			if v.Status.IsPresent() {
				statuses = append(statuses, StudentStatusPresent)
			} else {
				statuses = append(statuses, StudentStatusMissing)
			}
		}
	}

	if student.Free {
		statuses = append(statuses, StudentStatusFree)
		return statuses
	}

	studentLessons := make(map[uuid.UUID]response.LessonResponse)
	for _, v := range visits {
		if l, ok := lessonsMap[v.LessonID]; ok {
			studentLessons[v.LessonID] = l
		}
	}

	lastLesson := lesson.FindLatestLesson(studentLessons)

	referenceDate := today
	if lastLesson != nil {
		referenceDate = lastLesson.Date
	}

	maxPaidUntil := transaction.MaxPaidUntil(payments)

	if transaction.IsSubscriptionActive(maxPaidUntil, referenceDate) {
		statuses = append(statuses, StudentStatusPaid)
	} else {
		statuses = append(statuses, StudentStatusUnpaid)
	}

	return statuses
}
