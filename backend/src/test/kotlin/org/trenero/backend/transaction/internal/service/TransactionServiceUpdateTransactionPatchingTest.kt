package org.trenero.backend.transaction.internal.service

import jakarta.persistence.EntityNotFoundException
import java.math.BigDecimal
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestDays
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository
import org.trenero.backend.transaction.internal.repository.TransactionRepository
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The patch behind {@code PATCH /api/v1/transactions/{transactionId}}: amount, date and the
 * `paidUntil` of the payment details are updated, nothing else is touched.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class TransactionServiceUpdateTransactionPatchingTest {

  @Autowired private lateinit var transactionRepository: TransactionRepository
  @Autowired private lateinit var studentPaymentRepository: StudentPaymentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val amount = BigDecimal("3800.00")
  private val studentId = UUID.randomUUID()
  private val date = TestDays.day(2026, 10, 8)
  private val paidUntil = TestDays.day(2026, 11, 8)

  @Test
  fun patchesTheAmountTheDateAndThePaidUntil() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)
    val newAmount = BigDecimal("4200.00")
    val newDate = TestDays.day(2026, 10, 9)
    val newPaidUntil = TestDays.day(2026, 12, 9)

    val response =
      service()
        .updateTransaction(
          transactionId,
          updates(
            "amount" to newAmount.toString(),
            "date" to newDate.toString(),
            "paidUntil" to newPaidUntil.toString(),
          ),
          owner,
        )

    assertThat(response.amount).isEqualByComparingTo(newAmount)
    assertThat(response.date).isEqualTo(newDate)
    assertThat((response.paymentDetails as StudentPaymentDetailsResponse).paidUntil)
      .isEqualTo(newPaidUntil)
    assertThat(studentPaymentRepository.findById(transactionId).orElseThrow().paidUntil)
      .isEqualTo(newPaidUntil)
  }

  /**
   * A null inside the patch body belongs to a column that cannot be null, so it must not be written
   * through: the patch used to wipe the amount and the response mapping then hit the non-null
   * Kotlin field of {@code TransactionResponse}.
   */
  @Test
  fun ignoresANullAmount() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)

    val response = service().updateTransaction(transactionId, updates("amount" to null), owner)

    assertThat(response.amount).isEqualByComparingTo(amount)
    assertThat(transactionRepository.findById(transactionId).orElseThrow().amount)
      .isEqualByComparingTo(amount)
  }

  @Test
  fun ignoresANullDate() {
    val owner = userRepository.insertOwner()
    val transactionId = createPayment(owner)

    val response = service().updateTransaction(transactionId, updates("date" to null), owner)

    assertThat(response.date).isEqualTo(date)
  }

  @Test
  fun ignoresAPaidUntilWithoutPaymentDetails() {
    val owner = userRepository.insertOwner()
    val transaction =
      service()
        .createTransaction(
          CreateTransactionRequest(
            amount,
            date,
            TransactionType.EXPENSE,
            null,
          ),
          owner,
        )

    val response =
      service()
        .updateTransaction(transaction.id, updates("paidUntil" to paidUntil.toString()), owner)

    assertThat(response.paymentDetails).isNull()
  }

  @Test
  fun rejectsAnUnknownTransaction() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable {
      service().updateTransaction(UUID.randomUUID(), updates("amount" to "100.00"), owner)
    }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun hidesTheTransactionOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignTransactionId = createPayment(stranger)

    val thrown = catchThrowable {
      service().updateTransaction(foreignTransactionId, updates("amount" to "100.00"), owner)
    }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(transactionRepository.findById(foreignTransactionId).orElseThrow().amount)
      .isEqualByComparingTo(amount)
  }

  private fun service() = transactionService(transactionRepository, studentPaymentRepository)

  private fun createPayment(owner: JwtUser): UUID =
    service().createStudentPayment(studentId, amount, date, paidUntil, owner).id

  private fun updates(vararg entries: Pair<String, Any?>): Map<String, Any?> = mapOf(*entries)
}
