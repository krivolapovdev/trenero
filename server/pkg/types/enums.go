package types

import (
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

type OAuth2Provider string

const (
	OAuth2ProviderGoogle OAuth2Provider = "GOOGLE"
	OAuth2ProviderApple  OAuth2Provider = "APPLE"
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
