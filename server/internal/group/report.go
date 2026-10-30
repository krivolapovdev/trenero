package group

import (
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/visit"
)

func BuildGroupReport(
	grp response.GroupResponse,
	year, month int,
	students []response.StudentResponse,
	lessons []response.LessonResponse,
	visitsByStudentID map[uuid.UUID][]visit.VisitResponse,
	paymentsByStudentID map[uuid.UUID][]transaction.TransactionResponse,
	today time.Time,
) GroupReportResponse {
	lastDay := time.Date(year, time.Month(month)+1, 0, 0, 0, 0, 0, time.UTC)
	dayCount := lastDay.Day()

	sortedLessons := make([]response.LessonResponse, len(lessons))
	copy(sortedLessons, lessons)
	sort.Slice(sortedLessons, func(i, j int) bool {
		return sortedLessons[i].Date.Before(sortedLessons[j].Date)
	})

	lessonIDsByDay := make(map[int][]uuid.UUID)
	totalLessonsInMonth := 0
	for _, l := range sortedLessons {
		if l.Date.Year() == year && int(l.Date.Month()) == month {
			day := l.Date.Day()
			lessonIDsByDay[day] = append(lessonIDsByDay[day], l.ID)
			totalLessonsInMonth++
		}
	}

	lessonDays := make([]int, 0, len(lessonIDsByDay))
	for day := range lessonIDsByDay {
		lessonDays = append(lessonDays, day)
	}
	sort.Ints(lessonDays)

	statusesByStudentID := make(map[uuid.UUID]map[uuid.UUID][]visit.VisitStatus, len(visitsByStudentID))
	for sid, visits := range visitsByStudentID {
		byLesson := make(map[uuid.UUID][]visit.VisitStatus, len(visits))
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

	rows := make([]GroupReportStudentResponse, 0, len(sortedStudents))
	totalPresent := 0
	totalLessons := 0

	for _, student := range sortedStudents {
		statusesByLessonID := statusesByStudentID[student.ID]
		presentDays := make([]int, 0)
		dayMarks := make([]GroupReportDayMarkResponse, 0, len(lessonDays))
		studentPresentCount := 0

		for _, day := range lessonDays {
			lIDs := lessonIDsByDay[day]
			marks := make([]bool, 0, len(lIDs))
			for _, lessonID := range lIDs {
				stList := statusesByLessonID[lessonID]
				isPresent := false
				for _, st := range stList {
					if st == visit.VisitStatusPresent {
						isPresent = true
						break
					}
				}
				marks = append(marks, isPresent)
				if isPresent {
					presentDays = append(presentDays, day)
					studentPresentCount++
				}
			}
			dayMarks = append(dayMarks, GroupReportDayMarkResponse{
				Day:   day,
				Marks: marks,
			})
		}

		paid := isPaid(paymentsByStudentID[student.ID], year, month, today)
		totalPresent += studentPresentCount
		totalLessons += totalLessonsInMonth

		rows = append(rows, GroupReportStudentResponse{
			StudentID:    student.ID,
			FullName:     student.FullName,
			Paid:         paid,
			PresentDays:  presentDays,
			DayMarks:     dayMarks,
			PresentCount: studentPresentCount,
			LessonCount:  totalLessonsInMonth,
		})
	}

	return GroupReportResponse{
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

func isPaid(payments []transaction.TransactionResponse, year, month int, today time.Time) bool {
	maxPaidUntil := transaction.MaxPaidUntil(payments)
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

	return transaction.IsSubscriptionActive(maxPaidUntil, referenceDate)
}
