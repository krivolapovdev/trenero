package roster

import (
	"time"

	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
)

func toRosterResponse(r db.RostersModuleRoster, countOfStudents int64, students []response.StudentResponse) response.RosterResponse {
	var rosterDate *time.Time
	if r.RosterDate.Valid {
		rosterDate = &r.RosterDate.Time
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
		RosterDate:      rosterDate,
		Note:            note,
		CreatedAt:       r.CreatedAt,
		CountOfStudents: countOfStudents,
		Students:        students,
	}
}
