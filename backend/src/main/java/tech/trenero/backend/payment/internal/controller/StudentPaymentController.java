package tech.trenero.backend.payment.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.request.CreateStudentPaymentRequest;
import tech.trenero.backend.payment.internal.request.UpdatePaymentRequest;
import tech.trenero.backend.payment.internal.service.StudentPaymentService;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Validated
public class StudentPaymentController {
  private final StudentPaymentService studentPaymentService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<StudentPaymentResponse> getPayments(@AuthenticationPrincipal JwtUser jwtUser) {
    return studentPaymentService.getAllStudentPayments(jwtUser);
  }

  @GetMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  public StudentPaymentResponse getPayment(
      @PathVariable("paymentId") UUID paymentId, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentPaymentService.getStudentPaymentById(paymentId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public StudentPaymentResponse createPayment(
      @RequestBody @Valid CreateStudentPaymentRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return studentPaymentService.createStudentPayment(request, jwtUser);
  }

  @PatchMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  public StudentPaymentResponse updatePayment(
      @PathVariable("paymentId") UUID paymentId,
      @RequestBody @Valid UpdatePaymentRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return studentPaymentService.updateStudentPayment(paymentId, request, jwtUser);
  }

  @DeleteMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deletePayment(
      @PathVariable UUID paymentId, @AuthenticationPrincipal JwtUser jwtUser) {
    studentPaymentService.deleteStudentPaymentById(paymentId, jwtUser);
  }
}
