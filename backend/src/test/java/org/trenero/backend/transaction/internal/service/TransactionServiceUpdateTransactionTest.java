package org.trenero.backend.transaction.internal.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.trenero.backend.TestcontainersConfig;
import org.trenero.backend.common.domain.OAuth2Provider;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.transaction.internal.mapper.TransactionMapperImpl;
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository;
import org.trenero.backend.transaction.internal.repository.TransactionRepository;
import org.trenero.backend.user.internal.domain.OAuth2User;
import org.trenero.backend.user.internal.repository.UserRepository;

/**
 * Regression tests for patching the {@code paidUntil} of a student payment through {@code PATCH
 * /api/v1/transactions/{transactionId}}. The payment lives in a separate {@code student_payments}
 * table that is not cascaded from the transaction, so the update has to be persisted explicitly.
 */
@DataJpaTest
@Import(TestcontainersConfig.class)
class TransactionServiceUpdateTransactionTest {

  private static final LocalDate PAYMENT_DATE = LocalDate.of(2026, 10, 8);
  private static final LocalDate INITIAL_PAID_UNTIL = LocalDate.of(2026, 11, 8);

  @Autowired private TransactionRepository transactionRepository;
  @Autowired private StudentPaymentRepository studentPaymentRepository;
  @Autowired private UserRepository userRepository;

  @Test
  void updatesPaidUntilOfAStudentPayment() {
    JwtUser jwtUser = insertOwner();
    TransactionResponse created = createStudentPayment(jwtUser);
    LocalDate newPaidUntil = LocalDate.of(2026, 12, 8);

    TransactionResponse response =
        transactionService()
            .updateTransaction(
                created.getId(), Map.of("paidUntil", newPaidUntil.toString()), jwtUser);

    assertThat(response.getPaymentDetails()).isInstanceOf(StudentPaymentDetailsResponse.class);

    StudentPaymentDetailsResponse details =
        (StudentPaymentDetailsResponse) response.getPaymentDetails();
    assertThat(details.getPaidUntil()).isEqualTo(newPaidUntil);

    assertThat(studentPaymentRepository.findById(created.getId()).orElseThrow().getPaidUntil())
        .isEqualTo(newPaidUntil);
  }

  private TransactionResponse createStudentPayment(JwtUser jwtUser) {
    return transactionService()
        .createStudentPayment(
            UUID.randomUUID(),
            new BigDecimal("3800.00"),
            PAYMENT_DATE,
            INITIAL_PAID_UNTIL,
            jwtUser);
  }

  private TransactionService transactionService() {
    // studentSpi is only used to validate the student when payment details are present.
    return new TransactionService(
        transactionRepository,
        studentPaymentRepository,
        new TransactionMapperImpl(),
        mock(StudentSpi.class));
  }

  private JwtUser insertOwner() {
    OAuth2User owner =
        userRepository.saveAndFlush(
            OAuth2User.builder()
                .provider(OAuth2Provider.GOOGLE)
                .providerId(UUID.randomUUID().toString())
                .email(UUID.randomUUID() + "@example.com")
                .build());

    return new JwtUser(owner.getId(), owner.getEmail());
  }
}
