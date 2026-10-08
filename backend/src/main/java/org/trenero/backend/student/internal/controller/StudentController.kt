package org.trenero.backend.student.internal.controller

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
import org.trenero.backend.student.external.response.StudentResponse
import org.trenero.backend.student.internal.request.CreateStudentPaymentRequest
import org.trenero.backend.student.internal.request.CreateStudentRequest
import org.trenero.backend.student.internal.response.StudentSummaryResponse
import org.trenero.backend.student.internal.response.VisitWithLessonResponse
import org.trenero.backend.student.internal.service.StudentService
import org.trenero.backend.transaction.external.response.TransactionResponse

@RestController
@RequestMapping("/api/v1/students")
class StudentController(private val studentService: StudentService) {

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  fun getStudents(@AuthenticationPrincipal jwtUser: JwtUser): List<StudentResponse> =
    studentService.getAllStudents(jwtUser)

  @GetMapping("/overview")
  @PreAuthorize("isAuthenticated()")
  fun getStudentsSummary(@AuthenticationPrincipal jwtUser: JwtUser): List<StudentSummaryResponse> =
    studentService.getStudentsSummary(jwtUser)

  @GetMapping("/{studentId}")
  @PreAuthorize("isAuthenticated()")
  fun getStudent(
    @PathVariable studentId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): StudentResponse = studentService.getStudentById(studentId, jwtUser)

  @GetMapping("/{studentId}/visits")
  @PreAuthorize("isAuthenticated()")
  fun getStudentVisits(
    @PathVariable studentId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): List<VisitWithLessonResponse> = studentService.getStudentVisits(studentId, jwtUser)

  @GetMapping("/{studentId}/payments")
  @PreAuthorize("isAuthenticated()")
  fun getStudentPayments(
    @PathVariable studentId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): List<TransactionResponse> = studentService.getStudentPayments(studentId, jwtUser)

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  fun createStudent(
    @RequestBody @Valid request: CreateStudentRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): StudentResponse = studentService.createStudent(request, jwtUser)

  @PostMapping("/{studentId}/payments")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  fun createStudentPayment(
    @PathVariable studentId: UUID,
    @RequestBody @Valid request: CreateStudentPaymentRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): TransactionResponse = studentService.createStudentPayment(studentId, request, jwtUser)

  @PatchMapping("/{studentId}")
  @PreAuthorize("isAuthenticated()")
  fun updateStudent(
    @PathVariable studentId: UUID,
    @RequestBody request: Map<String, Any?>,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): StudentResponse = studentService.updateStudent(studentId, request, jwtUser)

  @DeleteMapping("/{studentId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  fun deleteStudent(
    @PathVariable studentId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ) = studentService.deleteStudent(studentId, jwtUser)
}
