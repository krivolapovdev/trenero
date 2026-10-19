package student

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/visit"
	"github.com/stretchr/testify/assert"
)

func TestStudentStatus_IndividualLessonLast(t *testing.T) {
	studentID := uuid.New()
	groupID := uuid.New()
	groupLessonID := uuid.New()
	individualLessonID := uuid.New()
	createdAt := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)

	st := response.StudentResponse{
		ID:        studentID,
		FullName:  "Test Student",
		Free:      false,
		CreatedAt: createdAt,
	}

	visits := []response.VisitResponse{
		{ID: uuid.New(), LessonID: groupLessonID, StudentID: studentID, Status: visit.VisitStatusAbsent},
		{ID: uuid.New(), LessonID: individualLessonID, StudentID: studentID, Status: visit.VisitStatusPresent},
	}

	lessonsMap := map[uuid.UUID]response.LessonResponse{
		groupLessonID: {
			ID:        groupLessonID,
			GroupID:   &groupID,
			Date:      time.Date(2026, 9, 1, 10, 0, 0, 0, time.UTC),
			CreatedAt: createdAt,
		},
		individualLessonID: {
			ID:        individualLessonID,
			GroupID:   nil,
			Date:      time.Date(2026, 10, 8, 10, 0, 0, 0, time.UTC),
			CreatedAt: createdAt,
		},
	}

	statuses := ComputeStudentStatuses(st, visits, nil, lessonsMap, time.Now().UTC())

	assert.Contains(t, statuses, StudentStatusPresent)
	assert.NotContains(t, statuses, StudentStatusMissing)
}

func TestStudentStatus_GroupLessonLast(t *testing.T) {
	studentID := uuid.New()
	groupID := uuid.New()
	groupLessonID := uuid.New()
	individualLessonID := uuid.New()
	createdAt := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)

	st := response.StudentResponse{
		ID:        studentID,
		FullName:  "Test Student",
		Free:      false,
		CreatedAt: createdAt,
	}

	visits := []response.VisitResponse{
		{ID: uuid.New(), LessonID: individualLessonID, StudentID: studentID, Status: visit.VisitStatusPresent},
		{ID: uuid.New(), LessonID: groupLessonID, StudentID: studentID, Status: visit.VisitStatusAbsent},
	}

	lessonsMap := map[uuid.UUID]response.LessonResponse{
		individualLessonID: {
			ID:        individualLessonID,
			GroupID:   nil,
			Date:      time.Date(2026, 9, 1, 10, 0, 0, 0, time.UTC),
			CreatedAt: createdAt,
		},
		groupLessonID: {
			ID:        groupLessonID,
			GroupID:   &groupID,
			Date:      time.Date(2026, 10, 8, 10, 0, 0, 0, time.UTC),
			CreatedAt: createdAt,
		},
	}

	statuses := ComputeStudentStatuses(st, visits, nil, lessonsMap, time.Now().UTC())

	assert.Contains(t, statuses, StudentStatusMissing)
	assert.NotContains(t, statuses, StudentStatusPresent)
}

func TestStudentStatus_PrefersLessonCreatedLastOnSameDay(t *testing.T) {
	studentID := uuid.New()
	groupID := uuid.New()
	groupLessonID := uuid.New()
	individualLessonID := uuid.New()
	createdAt := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)
	day := time.Date(2026, 10, 8, 10, 0, 0, 0, time.UTC)

	st := response.StudentResponse{
		ID:        studentID,
		FullName:  "Test Student",
		Free:      false,
		CreatedAt: createdAt,
	}

	visits := []response.VisitResponse{
		{ID: uuid.New(), LessonID: groupLessonID, StudentID: studentID, Status: visit.VisitStatusAbsent},
		{ID: uuid.New(), LessonID: individualLessonID, StudentID: studentID, Status: visit.VisitStatusPresent},
	}

	lessonsMap := map[uuid.UUID]response.LessonResponse{
		groupLessonID: {
			ID:        groupLessonID,
			GroupID:   &groupID,
			Date:      day,
			CreatedAt: createdAt,
		},
		individualLessonID: {
			ID:        individualLessonID,
			GroupID:   nil,
			Date:      day,
			CreatedAt: createdAt.Add(2 * time.Hour),
		},
	}

	statuses := ComputeStudentStatuses(st, visits, nil, lessonsMap, time.Now().UTC())

	assert.Contains(t, statuses, StudentStatusPresent)
	assert.NotContains(t, statuses, StudentStatusMissing)
}

func TestStudentStatus_InactiveWhenNoVisitsAndNoPayments(t *testing.T) {
	studentID := uuid.New()
	createdAt := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)

	stNotFree := response.StudentResponse{
		ID:        studentID,
		FullName:  "Inactive Student",
		Free:      false,
		CreatedAt: createdAt,
	}
	statuses := ComputeStudentStatuses(stNotFree, nil, nil, nil, time.Now().UTC())
	assert.Equal(t, []StudentStatus{StudentStatusInactive}, statuses)

	stFree := response.StudentResponse{
		ID:        studentID,
		FullName:  "Free Student",
		Free:      true,
		CreatedAt: createdAt,
	}
	freeStatuses := ComputeStudentStatuses(stFree, nil, nil, nil, time.Now().UTC())
	assert.Equal(t, []StudentStatus{StudentStatusFree}, freeStatuses)
}

func TestStudentStatus_PaidVsUnpaid(t *testing.T) {
	studentID := uuid.New()
	lessonID := uuid.New()
	createdAt := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)
	lastLessonDay := time.Date(2026, 10, 8, 10, 0, 0, 0, time.UTC)

	st := response.StudentResponse{
		ID:        studentID,
		FullName:  "Paying Student",
		Free:      false,
		CreatedAt: createdAt,
	}

	visits := []response.VisitResponse{
		{ID: uuid.New(), LessonID: lessonID, StudentID: studentID, Status: visit.VisitStatusPresent},
	}

	lessonsMap := map[uuid.UUID]response.LessonResponse{
		lessonID: {
			ID:        lessonID,
			Date:      lastLessonDay,
			CreatedAt: createdAt,
		},
	}

	activePayments := []transaction.TransactionResponse{
		{
			ID:        uuid.New(),
			Amount:    1000,
			CreatedAt: createdAt,
			PaymentDetails: &transaction.StudentPaymentDetailsResponse{
				StudentID: studentID,
				PaidUntil: lastLessonDay,
			},
		},
	}

	statusesPaid := ComputeStudentStatuses(st, visits, activePayments, lessonsMap, time.Now().UTC())
	assert.Contains(t, statusesPaid, StudentStatusPaid)
	assert.NotContains(t, statusesPaid, StudentStatusUnpaid)

	expiredPayments := []transaction.TransactionResponse{
		{
			ID:        uuid.New(),
			Amount:    1000,
			CreatedAt: createdAt,
			PaymentDetails: &transaction.StudentPaymentDetailsResponse{
				StudentID: studentID,
				PaidUntil: lastLessonDay.AddDate(0, 0, -1),
			},
		},
	}

	statusesUnpaid := ComputeStudentStatuses(st, visits, expiredPayments, lessonsMap, time.Now().UTC())
	assert.Contains(t, statusesUnpaid, StudentStatusUnpaid)
	assert.NotContains(t, statusesUnpaid, StudentStatusPaid)
}

func TestStudentStatus_FreeStudent(t *testing.T) {
	studentID := uuid.New()
	lessonID := uuid.New()
	createdAt := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)
	lastLessonDay := time.Date(2026, 10, 8, 10, 0, 0, 0, time.UTC)

	st := response.StudentResponse{
		ID:        studentID,
		FullName:  "Free Student",
		Free:      true,
		CreatedAt: createdAt,
	}

	visits := []response.VisitResponse{
		{ID: uuid.New(), LessonID: lessonID, StudentID: studentID, Status: visit.VisitStatusPresent},
	}

	lessonsMap := map[uuid.UUID]response.LessonResponse{
		lessonID: {
			ID:        lessonID,
			Date:      lastLessonDay,
			CreatedAt: createdAt,
		},
	}

	statuses := ComputeStudentStatuses(st, visits, nil, lessonsMap, time.Now().UTC())
	assert.Contains(t, statuses, StudentStatusFree)
	assert.Contains(t, statuses, StudentStatusPresent)
	assert.NotContains(t, statuses, StudentStatusPaid)
	assert.NotContains(t, statuses, StudentStatusUnpaid)
}

func TestStudentStatus_GroupScopedVisits(t *testing.T) {
	studentID := uuid.New()
	groupID := uuid.New()
	groupLessonID := uuid.New()
	individualLessonID := uuid.New()
	createdAt := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)
	groupLessonDay := time.Date(2026, 9, 1, 10, 0, 0, 0, time.UTC)
	individualLessonDay := time.Date(2026, 10, 8, 10, 0, 0, 0, time.UTC)

	st := response.StudentResponse{
		ID:        studentID,
		FullName:  "Student",
		Free:      false,
		CreatedAt: createdAt,
	}

	visits := []response.VisitResponse{
		{ID: uuid.New(), LessonID: groupLessonID, StudentID: studentID, Status: visit.VisitStatusAbsent},
		{ID: uuid.New(), LessonID: individualLessonID, StudentID: studentID, Status: visit.VisitStatusPresent},
	}

	everyLessonMap := map[uuid.UUID]response.LessonResponse{
		groupLessonID: {
			ID:        groupLessonID,
			GroupID:   &groupID,
			Date:      groupLessonDay,
			CreatedAt: createdAt,
		},
		individualLessonID: {
			ID:        individualLessonID,
			GroupID:   nil,
			Date:      individualLessonDay,
			CreatedAt: createdAt,
		},
	}

	groupLessonsMap := map[uuid.UUID]response.LessonResponse{
		groupLessonID: {
			ID:        groupLessonID,
			GroupID:   &groupID,
			Date:      groupLessonDay,
			CreatedAt: createdAt,
		},
	}

	payments := []response.TransactionResponse{
		{
			ID:        uuid.New(),
			Amount:    1000,
			CreatedAt: createdAt,
			PaymentDetails: &response.StudentPaymentDetailsResponse{
				StudentID: studentID,
				PaidUntil: time.Date(2026, 9, 15, 0, 0, 0, 0, time.UTC),
			},
		},
	}

	statuses := ComputeStudentStatusesWithVisitLessons(st, visits, payments, everyLessonMap, groupLessonsMap, time.Now().UTC())
	assert.Contains(t, statuses, StudentStatusMissing)
	assert.Contains(t, statuses, StudentStatusUnpaid)
	assert.NotContains(t, statuses, StudentStatusPresent)
	assert.NotContains(t, statuses, StudentStatusPaid)
}
