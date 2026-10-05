package org.trenero.backend.payment.internal.controller

import jakarta.validation.Valid
import java.util.UUID
import org.springframework.http.HttpStatus
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.payment.external.response.StudentPaymentResponse
import org.trenero.backend.payment.internal.request.CreateStudentPaymentRequest
import org.trenero.backend.payment.internal.request.UpdatePaymentRequest
import org.trenero.backend.payment.internal.service.StudentPaymentService

@RestController
@RequestMapping("/api/v1/payments")
class StudentPaymentController(private val studentPaymentService: StudentPaymentService) {

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  fun getPayments(@AuthenticationPrincipal jwtUser: JwtUser): List<StudentPaymentResponse> =
    studentPaymentService.getAllStudentPayments(jwtUser)

  @GetMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  fun getPayment(
    @PathVariable paymentId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): StudentPaymentResponse = studentPaymentService.getStudentPaymentById(paymentId, jwtUser)

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  fun createPayment(
    @RequestBody @Valid request: CreateStudentPaymentRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): StudentPaymentResponse = studentPaymentService.createStudentPayment(request, jwtUser)

  @PatchMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  fun updatePayment(
    @PathVariable paymentId: UUID,
    @RequestBody @Valid request: UpdatePaymentRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): StudentPaymentResponse =
    studentPaymentService.updateStudentPayment(paymentId, request, jwtUser)

  @DeleteMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  fun deletePayment(
    @PathVariable paymentId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ) {
    studentPaymentService.deleteStudentPaymentById(paymentId, jwtUser)
  }
}
