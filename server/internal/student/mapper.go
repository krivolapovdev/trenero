package student

import (
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
)

func toStudentResponse(s db.StudentsModuleStudent) response.StudentResponse {
	var birthdate *types.Date
	if s.Birthdate.Valid {
		birthdate = &types.Date{Time: s.Birthdate.Time}
	}
	var phone *string
	if s.Phone.Valid {
		phone = &s.Phone.String
	}
	var note *string
	if s.Note.Valid {
		note = &s.Note.String
	}
	return response.StudentResponse{
		ID:        s.ID,
		FullName:  s.FullName,
		Birthdate: birthdate,
		Phone:     phone,
		Note:      note,
		CreatedAt: s.CreatedAt,
		Free:      s.Free,
	}
}
