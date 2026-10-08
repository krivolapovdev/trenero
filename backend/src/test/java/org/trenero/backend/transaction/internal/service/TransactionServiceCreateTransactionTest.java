package org.trenero.backend.transaction.internal.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.trenero.backend.TestcontainersConfig;
import org.trenero.backend.common.domain.OAuth2Provider;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.transaction.internal.mapper.TransactionMapperImpl;
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository;
import org.trenero.backend.transaction.internal.repository.TransactionRepository;
import org.trenero.backend.transaction.internal.request.CreateStudentPaymentDetailsRequest;
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest;
import org.trenero.backend.user.internal.domain.OAuth2User;
import org.trenero.backend.user.internal.repository.UserRepository;

/**
 * Regression tests for the {@code createdAt} {@link NullPointerException} that used to break {@code
 * POST /api/v1/transactions}.
 *
 * <p>{@code Transaction.createdAt} is filled in by Hibernate's {@code @CreationTimestamp}, whose
 * value is only generated when the INSERT is executed. Mapping the entity straight after {@code
 * save()} (which only calls {@code persist}) therefore produced a {@code null} {@code createdAt},
 * and the Kotlin {@link TransactionResponse} constructor rejects a null {@code createdAt}.
 */
@DataJpaTest
@Import(TestcontainersConfig.class)
class TransactionServiceCreateTransactionTest {

  @Autowired private TransactionRepository transactionRepository;
  @Autowired private StudentPaymentRepository studentPaymentRepository;
  @Autowired private UserRepository userRepository;

  @Test
  void populatesCreatedAtForTransactionWithoutPaymentDetails() {
    JwtUser jwtUser = insertOwner();

    TransactionResponse response =
        transactionService()
            .createTransaction(
                new CreateTransactionRequest(
                    new BigDecimal("150.00"),
                    LocalDate.of(2026, 10, 8),
                    TransactionType.INCOME,
                    null),
                jwtUser);

    assertThat(response.getId()).isNotNull();
    assertThat(response.getCreatedAt())
        .as("createdAt must be generated before the response is mapped")
        .isNotNull();
    assertThat(response.getPaymentDetails()).isNull();
  }

  @Test
  void populatesCreatedAtForTransactionWithStudentPaymentDetails() {
    JwtUser jwtUser = insertOwner();
    UUID studentId = UUID.randomUUID();
    LocalDate paidUntil = LocalDate.of(2026, 11, 8);

    TransactionResponse response =
        transactionService()
            .createTransaction(
                new CreateTransactionRequest(
                    new BigDecimal("200.00"),
                    LocalDate.of(2026, 10, 8),
                    TransactionType.INCOME,
                    new CreateStudentPaymentDetailsRequest(studentId, paidUntil, null)),
                jwtUser);

    assertThat(response.getCreatedAt()).isNotNull();
    assertThat(response.getPaymentDetails()).isInstanceOf(StudentPaymentDetailsResponse.class);

    StudentPaymentDetailsResponse details =
        (StudentPaymentDetailsResponse) response.getPaymentDetails();
    assertThat(details).isNotNull();
    assertThat(details.getStudentId()).isEqualTo(studentId);
    assertThat(details.getPaidUntil()).isEqualTo(paidUntil);
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
