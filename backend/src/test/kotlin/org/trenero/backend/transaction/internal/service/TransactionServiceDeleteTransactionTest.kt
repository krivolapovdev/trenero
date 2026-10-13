package org.trenero.backend.transaction.internal.service

import jakarta.persistence.EntityNotFoundException
import java.math.BigDecimal
import java.time.LocalDate
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository
import org.trenero.backend.transaction.internal.repository.TransactionRepository
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The deletion behind {@code DELETE /api/v1/transactions/{transactionId}}. The student payment is
 * mapped by the inverse side of the relation, so Hibernate does not cascade the removal and the
 * payment row has to be removed explicitly before the transaction.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class TransactionServiceDeleteTransactionTest {

  @Autowired private lateinit var transactionRepository: TransactionRepository
  @Autowired private lateinit var studentPaymentRepository: StudentPaymentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val amount = BigDecimal("3800.00")
  private val date = LocalDate.of(2026, 10, 8)

  @Test
  fun removesTheTransactionAndItsStudentPayment() {
    val owner = userRepository.insertOwner()
    val transactionId =
      service().createStudentPayment(UUID.randomUUID(), amount, date, date, owner).id

    service().deleteTransaction(transactionId, owner)

    assertThat(transactionRepository.findById(transactionId).isPresent).isFalse()
    assertThat(studentPaymentRepository.findById(transactionId).isPresent).isFalse()
  }

  @Test
  fun removesATransactionWithoutPaymentDetails() {
    val owner = userRepository.insertOwner()
    val transaction =
      service()
        .createTransaction(
          CreateTransactionRequest(amount, date, TransactionType.EXPENSE, null),
          owner,
        )

    service().deleteTransaction(transaction.id, owner)

    assertThat(transactionRepository.findById(transaction.id).isPresent).isFalse()
  }

  @Test
  fun removesTheTransactionThroughTheSpi() {
    val owner = userRepository.insertOwner()
    val transactionId =
      service().createStudentPayment(UUID.randomUUID(), amount, date, date, owner).id

    service().deleteTransactionById(transactionId, owner)

    assertThat(transactionRepository.findById(transactionId).isPresent).isFalse()
    assertThat(studentPaymentRepository.findById(transactionId).isPresent).isFalse()
  }

  @Test
  fun rejectsAnUnknownTransaction() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().deleteTransaction(UUID.randomUUID(), owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun hidesTheTransactionOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignId = createPayment(stranger)

    val thrown = catchThrowable { service().deleteTransaction(foreignId, owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(transactionRepository.findById(foreignId).isPresent).isTrue()
    assertThat(studentPaymentRepository.findById(foreignId).isPresent).isTrue()
  }

  private fun service() = transactionService(transactionRepository, studentPaymentRepository)

  private fun createPayment(owner: JwtUser): UUID =
    service().createStudentPayment(UUID.randomUUID(), amount, date, date, owner).id
}
