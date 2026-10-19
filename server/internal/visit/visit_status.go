package visit

type VisitStatus string

const (
	VisitStatusPresent VisitStatus = "PRESENT"
	VisitStatusAbsent  VisitStatus = "ABSENT"
	VisitStatusExcused VisitStatus = "EXCUSED"
)

// IsPresent returns true if the visit status represents presence.
func (s VisitStatus) IsPresent() bool {
	return s == VisitStatusPresent
}
