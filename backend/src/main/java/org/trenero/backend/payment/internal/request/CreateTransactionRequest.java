package org.trenero.backend.payment.internal.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.trenero.backend.common.domain.TransactionType;

public record CreateTransactionRequest(
    @NotNull(message = "Amount is required") @Positive(message = "Amount must be strictly positive")
        BigDecimal amount,
    @NotNull(message = "Transaction type is required") TransactionType type,
    @NotNull(message = "Date is required") LocalDate date) {}
