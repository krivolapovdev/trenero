package types

import (
	"time"
)

// StudentStatus represents the status of a student
// @name StudentStatus
type StudentStatus string

const (
	StudentStatusInactive StudentStatus = "INACTIVE"
	StudentStatusPresent  StudentStatus = "PRESENT"
	StudentStatusMissing  StudentStatus = "MISSING"
	StudentStatusPaid     StudentStatus = "PAID"
	StudentStatusUnpaid   StudentStatus = "UNPAID"
	StudentStatusFree     StudentStatus = "FREE"
)

// VisitStatus represents the attendance status of a visit
// @name VisitStatus
type VisitStatus string

const (
	VisitStatusPresent VisitStatus = "PRESENT"
	VisitStatusAbsent  VisitStatus = "ABSENT"
	VisitStatusExcused VisitStatus = "EXCUSED"
)

// VisitType represents the billing type of a visit
// @name VisitType
type VisitType string

const (
	VisitTypeRegular VisitType = "REGULAR"
	VisitTypeFree    VisitType = "FREE"
)

// TransactionType represents the type of transaction
// @name TransactionType
type TransactionType string

const (
	TransactionTypeIncome  TransactionType = "INCOME"
	TransactionTypeExpense TransactionType = "EXPENSE"
)

// MetricScope represents the aggregation scope for payment statistics
// @name MetricScope
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
	ErrStudentNameNotUnique = "STUDENT_NAME_NOT_UNIQUE"
	ErrGroupNameNotUnique   = "GROUP_NAME_NOT_UNIQUE"
)

type Date struct {
	time.Time
}
