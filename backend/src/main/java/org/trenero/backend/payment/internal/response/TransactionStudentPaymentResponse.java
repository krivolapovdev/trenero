package org.trenero.backend.payment.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import org.trenero.backend.common.response.StudentResponse;

public record TransactionStudentPaymentResponse(
    @JsonUnwrapped @NotNull StudentResponse studentResponse, @NotNull LocalDate paidUntil) {}
