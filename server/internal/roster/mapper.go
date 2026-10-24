package roster

import (
	"time"

	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
)

func toRosterResponse(r db.RostersModuleRoster, countOfStudents int64, students []response.StudentResponse) response.RosterResponse {
	var date *time.Time
	if r.Date.Valid {
		date = &r.Date.Time
	}

	var note *string
	if r.Note.Valid {
		note = &r.Note.String
	}

	if students == nil {
		students = []response.StudentResponse{}
	}

	return response.RosterResponse{
		ID:              r.ID,
		Name:            r.Name,
		Date:            date,
		Note:            note,
		CreatedAt:       r.CreatedAt,
		CountOfStudents: countOfStudents,
		Students:        students,
	}
}
