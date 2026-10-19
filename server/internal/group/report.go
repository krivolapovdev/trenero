package group

import (
	"github.com/krivolapovdev/trenerio/pkg/response"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
	timeutil "github.com/krivolapovdev/trenerio/pkg/utils"
)

func BuildGroupReport(
	grp response.GroupResponse,
	year, month int,
	students []response.StudentResponse,
	lessons []response.LessonResponse,
	visitsByStudentID map[uuid.UUID][]response.VisitResponse,
	paymentsByStudentID map[uuid.UUID][]response.TransactionResponse,
	today time.Time,
) response.GroupReportResponse {
	lastDay := time.Date(year, time.Month(month)+1, 0, 0, 0, 0, 0, time.UTC)
	dayCount := lastDay.Day()

	lessonIDsByDay := make(map[int][]uuid.UUID)
	for _, l := range lessons {
		if l.Date.Year() == year && int(l.Date.Month()) == month {
			day := l.Date.Day()
			lessonIDsByDay[day] = append(lessonIDsByDay[day], l.ID)
		}
	}

	lessonDays := make([]int, 0, len(lessonIDsByDay))
	for day := range lessonIDsByDay {
		lessonDays = append(lessonDays, day)
	}
	sort.Ints(lessonDays)

	statusesByStudentID := make(map[uuid.UUID]map[uuid.UUID][]types.VisitStatus, len(visitsByStudentID))
	for sid, visits := range visitsByStudentID {
		byLesson := make(map[uuid.UUID][]types.VisitStatus, len(visits))
		for _, v := range visits {
			byLesson[v.LessonID] = append(byLesson[v.LessonID], v.Status)
		}
		statusesByStudentID[sid] = byLesson
	}

	sortedStudents := make([]response.StudentResponse, len(students))
	copy(sortedStudents, students)
	sort.Slice(sortedStudents, func(i, j int) bool {
		return strings.ToLower(sortedStudents[i].FullName) < strings.ToLower(sortedStudents[j].FullName)
	})

	rows := make([]response.GroupReportStudentResponse, 0, len(sortedStudents))
	totalPresent := 0
	totalLessons := 0

	for _, student := range sortedStudents {
		statusesByLessonID := statusesByStudentID[student.ID]
		presentDays := make([]int, 0)
		for _, day := range lessonDays {
			for _, lessonID := range lessonIDsByDay[day] {
				stList := statusesByLessonID[lessonID]
				isPresent := false
				for _, st := range stList {
					if st == types.VisitStatusPresent {
						isPresent = true
						break
					}
				}
				if isPresent {
					presentDays = append(presentDays, day)
					break
				}
			}
		}

		paid := isPaid(paymentsByStudentID[student.ID], year, month, today)
		pCount := len(presentDays)
		lCount := len(lessonDays)
		totalPresent += pCount
		totalLessons += lCount

		rows = append(rows, response.GroupReportStudentResponse{
			StudentID:    student.ID,
			FullName:     student.FullName,
			Paid:         paid,
			PresentDays:  presentDays,
			PresentCount: pCount,
			LessonCount:  lCount,
		})
	}

	return response.GroupReportResponse{
		GroupID:      grp.ID,
		GroupName:    grp.Name,
		Year:         year,
		Month:        month,
		DayCount:     dayCount,
		LessonDays:   lessonDays,
		Students:     rows,
		TotalPresent: totalPresent,
		TotalLessons: totalLessons,
	}
}

func isPaid(payments []response.TransactionResponse, year, month int, today time.Time) bool {
	maxPaidUntil := timeutil.MaxPaidUntil(payments)
	if maxPaidUntil == nil {
		return false
	}

	todayDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, time.UTC)
	firstOfMonth := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastOfMonth := time.Date(year, time.Month(month)+1, 0, 0, 0, 0, 0, time.UTC)

	var referenceDate time.Time
	if firstOfMonth.After(todayDay) {
		referenceDate = firstOfMonth
	} else if lastOfMonth.Before(todayDay) {
		referenceDate = lastOfMonth
	} else {
		referenceDate = todayDay
	}

	return timeutil.IsSubscriptionActive(maxPaidUntil, referenceDate)
}
