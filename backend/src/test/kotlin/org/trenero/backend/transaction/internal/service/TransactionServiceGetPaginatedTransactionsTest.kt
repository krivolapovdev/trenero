package org.trenero.backend.transaction.internal.service

import java.math.BigDecimal
import java.time.LocalDate
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository
import org.trenero.backend.transaction.internal.repository.TransactionRepository
import org.trenero.backend.transaction.internal.request.CreateStudentPaymentDetailsRequest
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest
import org.trenero.backend.user.internal.repository.UserRepository

/** The paginated transaction list of the finance page. */
@DataJpaTest
@Import(TestcontainersConfig::class)
class TransactionServiceGetPaginatedTransactionsTest {

  @Autowired private lateinit var transactionRepository: TransactionRepository
  @Autowired private lateinit var studentPaymentRepository: StudentPaymentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val amount = BigDecimal("1000.00")

  @Test
  fun returnsTheTransactionsOfTheOwnerNewestFirst() {
    val owner = userRepository.insertOwner()
    createTransaction(owner, LocalDate.of(2026, 9, 1))
    createTransaction(owner, LocalDate.of(2026, 10, 1))
    createTransaction(owner, LocalDate.of(2026, 8, 1))

    val response = service().getPaginatedTransactions(1, 20, owner)

    assertThat(response.content.map { it.date })
      .containsExactly(
        LocalDate.of(2026, 10, 1),
        LocalDate.of(2026, 9, 1),
        LocalDate.of(2026, 8, 1),
      )
    assertThat(response.totalElements).isEqualTo(3)
  }

  @Test
  fun hidesTheTransactionsOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    createTransaction(owner, LocalDate.of(2026, 10, 1))
    createTransaction(stranger, LocalDate.of(2026, 10, 2))

    val response = service().getPaginatedTransactions(1, 20, owner)

    assertThat(response.content.map { it.date }).containsExactly(LocalDate.of(2026, 10, 1))
  }

  @Test
  fun appliesTheRequestedPageWindow() {
    val owner = userRepository.insertOwner()
    createTransaction(owner, LocalDate.of(2026, 8, 1))
    createTransaction(owner, LocalDate.of(2026, 9, 1))
    createTransaction(owner, LocalDate.of(2026, 10, 1))

    val secondPage = service().getPaginatedTransactions(2, 1, owner)

    assertThat(secondPage.content.map { it.date }).containsExactly(LocalDate.of(2026, 9, 1))
    assertThat(secondPage.totalElements).isEqualTo(3)
  }

  /**
   * The page index is floored at zero, but the page size is handed straight to the page request.
   */
  @Test
  fun clampsATooSmallPageIndex() {
    val owner = userRepository.insertOwner()
    createTransaction(owner, LocalDate.of(2026, 10, 1))

    assertThat(service().getPaginatedTransactions(0, 20, owner).content).hasSize(1)
  }

  /**
   * {@code PageRequest.of} rejects a size below one with an {@code IllegalArgumentException}, which
   * the client reads as a server failure. A size the client sent is a client error.
   */
  @Test
  fun rejectsAPageSizeBelowOne() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().getPaginatedTransactions(1, 0, owner) }

    assertThat(thrown).isInstanceOf(ResponseStatusException::class.java)
    assertThat((thrown as ResponseStatusException).statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
  }

  @Test
  fun keepsThePaymentDetailsOfAStudentPayment() {
    val owner = userRepository.insertOwner()
    createTransaction(owner, LocalDate.of(2026, 10, 1))

    val response = service().getPaginatedTransactions(1, 20, owner)

    assertThat(response.content).hasSize(1)
    assertThat(response.content.first().paymentDetails).isNotNull()
  }

  private fun service() = transactionService(transactionRepository, studentPaymentRepository)

  private fun createTransaction(owner: JwtUser, date: LocalDate) {
    service()
      .createTransaction(
        CreateTransactionRequest(
          amount,
          date,
          TransactionType.INCOME,
          CreateStudentPaymentDetailsRequest(UUID.randomUUID(), date, null),
        ),
        owner,
      )
  }
}
