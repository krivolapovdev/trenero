package group

import (
	"github.com/krivolapovdev/trenerio/pkg/response"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestBuildGroupReport_DayGrid(t *testing.T) {
	groupID := uuid.New()
	annaID := uuid.New()
	ivanID := uuid.New()
	createdAt := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	today := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)

	firstLessonID := uuid.New()
	secondLessonID := uuid.New()

	lessons := []response.LessonResponse{
		{ID: uuid.New(), Date: time.Date(2026, 2, 3, 10, 0, 0, 0, time.UTC), CreatedAt: createdAt, GroupID: &groupID},
		{ID: firstLessonID, Date: time.Date(2026, 2, 5, 10, 0, 0, 0, time.UTC), CreatedAt: createdAt, GroupID: &groupID},
		{ID: secondLessonID, Date: time.Date(2026, 2, 10, 10, 0, 0, 0, time.UTC), CreatedAt: createdAt, GroupID: &groupID},
		{ID: uuid.New(), Date: time.Date(2026, 3, 3, 10, 0, 0, 0, time.UTC), CreatedAt: createdAt, GroupID: &groupID},
	}

	visits := map[uuid.UUID][]response.VisitResponse{
		annaID: {
			{ID: uuid.New(), LessonID: firstLessonID, StudentID: annaID, Status: types.VisitStatusPresent, CreatedAt: createdAt},
			{ID: uuid.New(), LessonID: secondLessonID, StudentID: annaID, Status: types.VisitStatusPresent, CreatedAt: createdAt},
		},
		ivanID: {
			{ID: uuid.New(), LessonID: firstLessonID, StudentID: ivanID, Status: types.VisitStatusPresent, CreatedAt: createdAt},
			{ID: uuid.New(), LessonID: secondLessonID, StudentID: ivanID, Status: types.VisitStatusAbsent, CreatedAt: createdAt},
		},
	}

	grp := response.GroupResponse{
		ID:        groupID,
		Name:      "Beginners",
		CreatedAt: createdAt,
	}

	students := []response.StudentResponse{
		{ID: annaID, FullName: "Anna Smirnova", CreatedAt: createdAt},
		{ID: ivanID, FullName: "Ivan Petrov", CreatedAt: createdAt},
	}

	report := BuildGroupReport(grp, 2026, 2, students, lessons, visits, map[uuid.UUID][]response.TransactionResponse{}, today)

	assert.Equal(t, 28, report.DayCount)
	assert.Equal(t, []int{3, 5, 10}, report.LessonDays)
	require.Len(t, report.Students, 2)

	anna := report.Students[0]
	assert.Equal(t, "Anna Smirnova", anna.FullName)
	assert.Equal(t, []int{5, 10}, anna.PresentDays)
	assert.Equal(t, 2, anna.PresentCount)
	assert.Equal(t, 3, anna.LessonCount)

	ivan := report.Students[1]
	assert.Equal(t, "Ivan Petrov", ivan.FullName)
	assert.Equal(t, []int{5}, ivan.PresentDays)
	assert.Equal(t, 1, ivan.PresentCount)
	assert.Equal(t, 3, ivan.LessonCount)

	assert.Equal(t, 3, report.TotalPresent)
	assert.Equal(t, 6, report.TotalLessons)
}

func TestBuildGroupReport_OrderingAndEmpty(t *testing.T) {
	groupID := uuid.New()
	annaID := uuid.New()
	ivanID := uuid.New()
	createdAt := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	today := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)

	grp := response.GroupResponse{
		ID:        groupID,
		Name:      "Beginners",
		CreatedAt: createdAt,
	}

	lessons := []response.LessonResponse{
		{ID: uuid.New(), Date: time.Date(2026, 2, 3, 10, 0, 0, 0, time.UTC), CreatedAt: createdAt, GroupID: &groupID},
	}

	students := []response.StudentResponse{
		{ID: ivanID, FullName: "ivan petrov", CreatedAt: createdAt},
		{ID: annaID, FullName: "Anna Smirnova", CreatedAt: createdAt},
	}

	report := BuildGroupReport(grp, 2026, 2, students, lessons, map[uuid.UUID][]response.VisitResponse{}, map[uuid.UUID][]response.TransactionResponse{}, today)

	require.Len(t, report.Students, 2)
	assert.Equal(t, "Anna Smirnova", report.Students[0].FullName)
	assert.Equal(t, "ivan petrov", report.Students[1].FullName)
	assert.Equal(t, 0, report.TotalPresent)
	assert.Equal(t, 2, report.TotalLessons)

	emptyReport := BuildGroupReport(grp, 2026, 2, []response.StudentResponse{}, []response.LessonResponse{}, map[uuid.UUID][]response.VisitResponse{}, map[uuid.UUID][]response.TransactionResponse{}, today)
	assert.Empty(t, emptyReport.Students)
	assert.Equal(t, 0, emptyReport.TotalPresent)
	assert.Equal(t, 0, emptyReport.TotalLessons)
	assert.Equal(t, 28, emptyReport.DayCount)
}

func TestBuildGroupReport_PaidFlags(t *testing.T) {
	groupID := uuid.New()
	decID := uuid.New()
	noPayID := uuid.New()
	oct1ID := uuid.New()
	oct31ID := uuid.New()
	createdAt := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	today := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)

	grp := response.GroupResponse{
		ID:        groupID,
		Name:      "Beginners",
		CreatedAt: createdAt,
	}

	lessons := []response.LessonResponse{
		{ID: uuid.New(), Date: time.Date(2026, 2, 3, 10, 0, 0, 0, time.UTC), CreatedAt: createdAt, GroupID: &groupID},
	}

	students := []response.StudentResponse{
		{ID: decID, FullName: "Anna ExpiresInDecember", CreatedAt: createdAt},
		{ID: noPayID, FullName: "Boris WithoutPayments", CreatedAt: createdAt},
		{ID: oct1ID, FullName: "Cyril ExpiresInOctober", CreatedAt: createdAt},
		{ID: oct31ID, FullName: "Daria PaidThroughOctober", CreatedAt: createdAt},
	}

	payments := map[uuid.UUID][]response.TransactionResponse{
		decID: {
			{
				ID:        uuid.New(),
				Amount:    3000,
				Date:      createdAt,
				CreatedAt: createdAt,
				Type:      types.TransactionTypeIncome,
				PaymentDetails: &response.StudentPaymentDetailsResponse{
					StudentID: decID,
					PaidUntil: time.Date(2026, 12, 31, 23, 59, 59, 0, time.UTC),
				},
			},
		},
		oct1ID: {
			{
				ID:        uuid.New(),
				Amount:    3000,
				Date:      createdAt,
				CreatedAt: createdAt,
				Type:      types.TransactionTypeIncome,
				PaymentDetails: &response.StudentPaymentDetailsResponse{
					StudentID: oct1ID,
					PaidUntil: time.Date(2026, 10, 1, 23, 59, 59, 0, time.UTC),
				},
			},
		},
		oct31ID: {
			{
				ID:        uuid.New(),
				Amount:    3000,
				Date:      createdAt,
				CreatedAt: createdAt,
				Type:      types.TransactionTypeIncome,
				PaymentDetails: &response.StudentPaymentDetailsResponse{
					StudentID: oct31ID,
					PaidUntil: time.Date(2026, 10, 31, 23, 59, 59, 0, time.UTC),
				},
			},
		},
	}

	reportFeb := BuildGroupReport(grp, 2026, 2, students, lessons, map[uuid.UUID][]response.VisitResponse{}, payments, today)
	var febPaid []bool
	for _, s := range reportFeb.Students {
		febPaid = append(febPaid, s.Paid)
	}
	assert.Equal(t, []bool{true, false, true, true}, febPaid)

	reportOct := BuildGroupReport(grp, 2026, 10, students, lessons, map[uuid.UUID][]response.VisitResponse{}, payments, today)
	var octPaid []bool
	for _, s := range reportOct.Students {
		octPaid = append(octPaid, s.Paid)
	}
	assert.Equal(t, []bool{true, false, false, true}, octPaid)

	reportDec := BuildGroupReport(grp, 2026, 12, students, lessons, map[uuid.UUID][]response.VisitResponse{}, payments, today)
	var decPaid []bool
	for _, s := range reportDec.Students {
		decPaid = append(decPaid, s.Paid)
	}
	assert.Equal(t, []bool{true, false, false, false}, decPaid)
}
