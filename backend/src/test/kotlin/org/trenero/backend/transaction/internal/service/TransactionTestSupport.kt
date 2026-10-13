package org.trenero.backend.transaction.internal.service

import java.util.UUID
import org.mockito.Mockito.mock
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.student.external.spi.StudentSpi
import org.trenero.backend.transaction.internal.mapper.TransactionMapperImpl
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository
import org.trenero.backend.transaction.internal.repository.TransactionRepository
import org.trenero.backend.user.internal.domain.OAuth2User
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * Builds the service under test. The student SPI is only asked whether a student exists; its result
 * is discarded by the service, so an unstubbed mock is enough and keeps the tests free of a student
 * module.
 */
internal fun transactionService(
  transactionRepository: TransactionRepository,
  studentPaymentRepository: StudentPaymentRepository,
): TransactionService =
  TransactionService(
    transactionRepository,
    studentPaymentRepository,
    TransactionMapperImpl(),
    mock(StudentSpi::class.java),
  )

/**
 * Persists an owner so that the transactions of the test satisfy the `fk_transactions_owner`
 * foreign key, and returns the principal the service is called with.
 */
internal fun UserRepository.insertOwner(): JwtUser {
  val owner =
    saveAndFlush(
      OAuth2User.builder()
        .provider(OAuth2Provider.GOOGLE)
        .providerId(UUID.randomUUID().toString())
        .email(UUID.randomUUID().toString() + "@example.com")
        .build()
    )

  return JwtUser(owner.id, owner.email)
}
