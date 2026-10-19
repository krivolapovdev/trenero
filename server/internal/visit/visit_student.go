package visit

import "github.com/google/uuid"

// @name StudentVisit
type StudentVisit struct {
	StudentID uuid.UUID   `json:"studentId" format:"uuid"`
	Status    VisitStatus `json:"status"`
	Type      VisitType   `json:"type"`
}
