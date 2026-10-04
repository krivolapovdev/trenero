package org.trenero.backend.payment.external

import java.util.UUID
import org.trenero.backend.common.response.StudentPaymentResponse
import org.trenero.backend.common.security.JwtUser

interface StudentPaymentSpi {
  fun getAllStudentPayments(jwtUser: JwtUser): List<StudentPaymentResponse>

  fun getStudentPaymentsByStudentId(
    studentId: UUID,
    jwtUser: JwtUser,
  ): List<StudentPaymentResponse>

  fun getStudentPaymentsByStudentIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, List<StudentPaymentResponse>>

  fun deleteStudentPaymentById(paymentId: UUID, jwtUser: JwtUser)
}
