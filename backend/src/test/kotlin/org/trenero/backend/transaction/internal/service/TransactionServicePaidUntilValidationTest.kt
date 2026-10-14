package org.trenero.backend.transaction.internal.service

import java.math.BigDecimal
import java.time.OffsetDateTime
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import org.trenero.backend.TestDays
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository
import org.trenero.backend.transaction.internal.repository.TransactionRepository
import org.trenero.backend.transaction.internal.request.CreateStudentPaymentDetailsRequest
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * A student payment covers a period: `paidUntil` is the last covered day and may never be earlier
 * than the day the money was paid (`date`).
 *
 * <p>The rule is enforced when a payment is created. It used to be enforced when a payment is
 * patched as well, but the patch path computed the effective date and then dropped it on the floor:
 * the value was only used to produce a dead local variable, so a payment could be moved into a
 * period its own create endpoint rejects.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class TransactionServicePaidUntilValidationTest {

  @Autowired private lateinit var transactionRepository: TransactionRepository
  @Autowired private lateinit var studentPaymentRepository: StudentPaymentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val amount = BigDecimal("3800.00")
  private val studentId = UUID.randomUUID()
  private val date = TestDays.day(2026, 10, 8)
  private val paidUntil = TestDays.day(2026, 11, 8)

  @Test
  fun rejectsAPaidUntilBeforeTheDateWhenAPaymentIsCreated() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable {
      service().createStudentPayment(studentId, amount, date, date.minusDays(1), owner)
    }

    assertBadRequest(thrown)
  }

  @Test
  fun acceptsAPaidUntilOnTheDateItselfWhenAPaymentIsCreated() {
    val owner = userRepository.insertOwner()

    val response = service().createStudentPayment(studentId, amount, date, date, owner)

    assertThat(paidUntilOf(response.paymentDetails)).isEqualTo(date)
  }

  @Test
  fun rejectsAPaidUntilBeforeTheDateOnTheTransactionEndpoint() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable {
      service()
        .createTransaction(
          CreateTransactionRequest(
            amount,
            date,
            TransactionType.INCOME,
            CreateStudentPaymentDetailsRequest(
              studentId,
              date.minusDays(1),
              null,
            ),
          ),
          owner,
        )
    }

    assertBadRequest(thrown)
  }

  @Test
  fun rejectsAPaidUntilBeforeThePaymentDateWhenThePaymentIsPatched() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)

    val thrown = catchThrowable {
      service()
        .updateTransaction(
          transactionId,
          updates("paidUntil" to date.minusDays(1).toString()),
          owner,
        )
    }

    assertBadRequest(thrown)
  }

  @Test
  fun rejectsAPaidUntilBeforeANewlyPatchedDate() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)

    val thrown = catchThrowable {
      service()
        .updateTransaction(
          transactionId,
          updates(
            "date" to TestDays.day(2026, 12, 1).toString(),
            "paidUntil" to paidUntil.toString(),
          ),
          owner,
        )
    }

    assertBadRequest(thrown)
  }

  @Test
  fun rejectsADateThatMovesThePaymentBehindItsPaidUntil() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)

    val thrown = catchThrowable {
      service()
        .updateTransaction(
          transactionId,
          updates("date" to paidUntil.plusDays(1).toString()),
          owner,
        )
    }

    assertBadRequest(thrown)
  }

  @Test
  fun acceptsAPaidUntilOnThePatchedDate() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)
    val newDate = TestDays.day(2026, 12, 1)

    val response =
      service()
        .updateTransaction(
          transactionId,
          updates("date" to newDate.toString(), "paidUntil" to newDate.toString()),
          owner,
        )

    assertThat(response.date).isEqualTo(newDate)
    assertThat(paidUntilOf(response.paymentDetails)).isEqualTo(newDate)
  }

  @Test
  fun acceptsAPaidUntilAfterThePatchedDate() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)
    val newPaidUntil = TestDays.day(2026, 12, 31)

    val response =
      service()
        .updateTransaction(
          transactionId,
          updates("paidUntil" to newPaidUntil.toString()),
          owner,
        )

    assertThat(paidUntilOf(response.paymentDetails)).isEqualTo(newPaidUntil)
  }

  private fun service() = transactionService(transactionRepository, studentPaymentRepository)

  private fun createPayment(owner: JwtUser): UUID =
    service().createStudentPayment(studentId, amount, date, paidUntil, owner).id

  private fun updates(vararg entries: Pair<String, Any?>): Map<String, Any?> = mapOf(*entries)

  private fun paidUntilOf(details: Any?): OffsetDateTime =
    (details as StudentPaymentDetailsResponse).paidUntil

  private fun assertBadRequest(thrown: Throwable?) {
    assertThat(thrown).isInstanceOf(ResponseStatusException::class.java)
    assertThat((thrown as ResponseStatusException).statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
  }
}
