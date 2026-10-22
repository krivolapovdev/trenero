package transaction

import (
	"strconv"

	"github.com/krivolapovdev/trenerio/internal/db"
)

func toTransactionResponse(tx db.PaymentsModuleTransaction, details *StudentPaymentDetailsResponse) TransactionResponse {
	amt, _ := strconv.ParseFloat(tx.Amount, 64)
	return TransactionResponse{
		ID:             tx.ID,
		Amount:         amt,
		Date:           tx.Date,
		Type:           TransactionType(tx.Type),
		CreatedAt:      tx.CreatedAt,
		PaymentDetails: details,
	}
}

func toTransactionResponseFromPaginatedRow(r db.FindTransactionsByOwnerIDPaginatedRow, details *StudentPaymentDetailsResponse) TransactionResponse {
	amt, _ := strconv.ParseFloat(r.Amount, 64)
	return TransactionResponse{
		ID:             r.ID,
		Amount:         amt,
		Date:           r.Date,
		Type:           TransactionType(r.Type),
		CreatedAt:      r.CreatedAt,
		PaymentDetails: details,
	}
}

func toTransactionResponseFromDateBetweenRow(r db.FindTransactionsByOwnerIDAndDateBetweenRow) TransactionResponse {
	amt, _ := strconv.ParseFloat(r.Amount, 64)
	return TransactionResponse{
		ID:        r.ID,
		Amount:    amt,
		Date:      r.Date,
		Type:      TransactionType(r.Type),
		CreatedAt: r.CreatedAt,
	}
}

func toTransactionResponseFromStudentPaymentRow(r db.FindStudentPaymentsByStudentIDAndOwnerIDRow) TransactionResponse {
	amt, _ := strconv.ParseFloat(r.Amount, 64)
	return TransactionResponse{
		ID:        r.ID,
		Amount:    amt,
		Date:      r.Date,
		Type:      TransactionType(r.Type),
		CreatedAt: r.CreatedAt,
		PaymentDetails: &StudentPaymentDetailsResponse{
			DetailsType: DetailsTypeStudent,
			StudentID:   r.StudentID,
			PaidUntil:   r.PaidUntil,
		},
	}
}

func toTransactionResponseFromStudentPaymentsRow(r db.FindStudentPaymentsByStudentIDsAndOwnerIDRow) TransactionResponse {
	amt, _ := strconv.ParseFloat(r.Amount, 64)
	return TransactionResponse{
		ID:        r.ID,
		Amount:    amt,
		Date:      r.Date,
		Type:      TransactionType(r.Type),
		CreatedAt: r.CreatedAt,
		PaymentDetails: &StudentPaymentDetailsResponse{
			DetailsType: DetailsTypeStudent,
			StudentID:   r.StudentID,
			PaidUntil:   r.PaidUntil,
		},
	}
}
