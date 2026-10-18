package types

import (
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
)

type StudentStatus string

const (
	StudentStatusInactive StudentStatus = "INACTIVE"
	StudentStatusPresent  StudentStatus = "PRESENT"
	StudentStatusMissing  StudentStatus = "MISSING"
	StudentStatusPaid     StudentStatus = "PAID"
	StudentStatusUnpaid   StudentStatus = "UNPAID"
	StudentStatusFree     StudentStatus = "FREE"
)

type VisitStatus string

const (
	VisitStatusPresent VisitStatus = "PRESENT"
	VisitStatusAbsent  VisitStatus = "ABSENT"
	VisitStatusExcused VisitStatus = "EXCUSED"
)

type VisitType string

const (
	VisitTypeRegular VisitType = "REGULAR"
	VisitTypeFree    VisitType = "FREE"
)

type TransactionType string

const (
	TransactionTypeIncome  TransactionType = "INCOME"
	TransactionTypeExpense TransactionType = "EXPENSE"
)

type MetricScope string

const (
	MetricScopeWeek  MetricScope = "WEEK"
	MetricScopeMonth MetricScope = "MONTH"
	MetricScopeYear  MetricScope = "YEAR"
)

const (
	TokenTypeAccess  = "ACCESS"
	TokenTypeRefresh = "REFRESH"
)

const (
	DetailsTypeStudent = "STUDENT"
)

const (
	ContextKeyJWTUser   = "jwtUser"
	ContextKeyRequestID = "requestID"
)

const (
	HeaderAuthorization = "Authorization"
	HeaderXRequestID    = "X-Request-ID"
	HeaderRequestID     = "Request-ID"
	HeaderXReviewerKey  = "X-Reviewer-Key"
	BearerPrefix        = "Bearer "
)

const (
	ErrStudentNameNotUnique = "STUDENT_NAME_NOT_UNIQUE"
	ErrGroupNameNotUnique   = "GROUP_NAME_NOT_UNIQUE"
)

type Date struct {
	time.Time
}

var dateFormats = []string{
	time.DateOnly,
	time.RFC3339,
	time.RFC3339Nano,
	"2006-01-02T15:04:05.000",
	"2006-01-02T15:04:05",
	"02.01.2006",
	"2006/01/02",
}

func ParseDate(s string) (Date, error) {
	s = strings.TrimSpace(s)
	if s == "" || s == "null" {
		return Date{}, nil
	}

	s = strings.Trim(s, `"`)
	if s == "" || s == "null" {
		return Date{}, nil
	}

	for _, layout := range dateFormats {
		if t, err := time.Parse(layout, s); err == nil {
			return Date{Time: t}, nil
		}
	}
	return Date{}, fmt.Errorf("invalid date format: %s", s)
}

func (d Date) MarshalJSON() ([]byte, error) {
	if d.IsZero() {
		return []byte("null"), nil
	}
	return []byte(`"` + d.Format(time.DateOnly) + `"`), nil
}

func (d *Date) UnmarshalJSON(data []byte) error {
	s := strings.TrimSpace(string(data))
	if s == "null" || s == `""` {
		*d = Date{}
		return nil
	}
	parsed, err := ParseDate(s)
	if err != nil {
		return err
	}
	*d = parsed
	return nil
}

func (d Date) String() string {
	if d.IsZero() {
		return ""
	}
	return d.Format(time.DateOnly)
}

func ParseUUIDSlice(raw any) []uuid.UUID {
	if raw == nil {
		return nil
	}
	switch v := raw.(type) {
	case []uuid.UUID:
		return v
	case []string:
		ids := make([]uuid.UUID, 0, len(v))
		for _, str := range v {
			if id, err := uuid.Parse(str); err == nil {
				ids = append(ids, id)
			}
		}
		return ids
	case []any:
		ids := make([]uuid.UUID, 0, len(v))
		for _, item := range v {
			if str, ok := item.(string); ok {
				if id, err := uuid.Parse(str); err == nil {
					ids = append(ids, id)
				}
			}
		}
		return ids
	case string:
		if id, err := uuid.Parse(v); err == nil {
			return []uuid.UUID{id}
		}
	}
	return nil
}
