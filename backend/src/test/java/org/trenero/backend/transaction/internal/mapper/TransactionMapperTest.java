package org.trenero.backend.transaction.internal.mapper;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.transaction.internal.domain.StudentPayment;
import org.trenero.backend.transaction.internal.domain.Transaction;

/**
 * Unit tests for the student name enrichment of {@link TransactionMapper#toResponse(Transaction,
 * Map)}. The name is not stored next to the payment, so views without an override title (the recent
 * transactions of the finance page, for example) only show the student of a payment when the name
 * is resolved from the students fetched by {@code TransactionService}.
 */
class TransactionMapperTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 10, 8, 12, 0, 0, 0, ZoneOffset.UTC);
  private static final LocalDate PAID_UNTIL = LocalDate.of(2026, 11, 8);

  private final TransactionMapper transactionMapper = new TransactionMapperImpl();

  @Test
  void resolvesStudentNameFromStudentsByIds() {
    UUID transactionId = UUID.randomUUID();
    UUID studentId = UUID.randomUUID();
    Transaction transaction = studentPaymentTransaction(transactionId, studentId);

    TransactionResponse response =
        transactionMapper.toResponse(
            transaction, Map.of(studentId, student(studentId, "Ivan Petrov")));

    assertThat(response.getPaymentDetails()).isInstanceOf(StudentPaymentDetailsResponse.class);

    StudentPaymentDetailsResponse details =
        (StudentPaymentDetailsResponse) response.getPaymentDetails();
    assertThat(details.getStudentName()).isEqualTo("Ivan Petrov");
    assertThat(details.getStudentId()).isEqualTo(studentId);
    assertThat(details.getPaidUntil()).isEqualTo(PAID_UNTIL);

    // The enrichment must not touch the transaction itself.
    assertThat(response.getId()).isEqualTo(transactionId);
    assertThat(response.getAmount()).isEqualByComparingTo("3800.00");
    assertThat(response.getDate()).isEqualTo(LocalDate.of(2026, 10, 8));
    assertThat(response.getType()).isEqualTo(TransactionType.INCOME);
    assertThat(response.getCreatedAt()).isEqualTo(CREATED_AT);
  }

  @Test
  void keepsPaymentDetailsWithoutStudentNameWhenTheStudentIsUnknown() {
    UUID transactionId = UUID.randomUUID();
    Transaction transaction = studentPaymentTransaction(transactionId, UUID.randomUUID());

    assertThat(detailsOf(transactionMapper.toResponse(transaction, Map.of())).getStudentName())
        .isNull();
    assertThat(detailsOf(transactionMapper.toResponse(transaction, null)).getStudentName())
        .isNull();
  }

  @Test
  void keepsTransactionsWithoutPaymentDetailsUntouched() {
    UUID transactionId = UUID.randomUUID();

    TransactionResponse response =
        transactionMapper.toResponse(withoutPaymentDetails(transactionId), Map.of());

    assertThat(response.getId()).isEqualTo(transactionId);
    assertThat(response.getType()).isEqualTo(TransactionType.EXPENSE);
    assertThat(response.getPaymentDetails()).isNull();
  }

  private static StudentPaymentDetailsResponse detailsOf(TransactionResponse response) {
    assertThat(response.getPaymentDetails()).isInstanceOf(StudentPaymentDetailsResponse.class);

    return (StudentPaymentDetailsResponse) response.getPaymentDetails();
  }

  private static Transaction studentPaymentTransaction(UUID transactionId, UUID studentId) {
    StudentPayment studentPayment =
        StudentPayment.builder()
            .transactionId(transactionId)
            .studentId(studentId)
            .paidUntil(PAID_UNTIL)
            .build();

    return Transaction.builder()
        .id(transactionId)
        .ownerId(UUID.randomUUID())
        .type(TransactionType.INCOME)
        .amount(new BigDecimal("3800.00"))
        .date(LocalDate.of(2026, 10, 8))
        .createdAt(CREATED_AT)
        .studentPayment(studentPayment)
        .build();
  }

  private static Transaction withoutPaymentDetails(UUID transactionId) {
    return Transaction.builder()
        .id(transactionId)
        .ownerId(UUID.randomUUID())
        .type(TransactionType.EXPENSE)
        .amount(new BigDecimal("500.00"))
        .date(LocalDate.of(2026, 10, 8))
        .createdAt(CREATED_AT)
        .build();
  }

  private static StudentResponse student(UUID studentId, String fullName) {
    return new StudentResponse(studentId, fullName, null, null, null, CREATED_AT);
  }
}
