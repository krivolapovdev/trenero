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
import tech.trenero.backend.common.response.PaymentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.request.CreatePaymentRequest;
import tech.trenero.backend.payment.internal.request.UpdatePaymentRequest;
import tech.trenero.backend.payment.internal.service.PaymentService;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Validated
public class PaymentController {
  private final PaymentService paymentService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<PaymentResponse> getPayments(@AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.getAllPayments(jwtUser);
  }

  @GetMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  public PaymentResponse getPayment(
      @PathVariable("paymentId") UUID paymentId, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.getPaymentById(paymentId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public PaymentResponse createPayment(
      @RequestBody @Valid CreatePaymentRequest request, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.createPayment(request, jwtUser);
  }

  @PatchMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  public PaymentResponse updatePayment(
      @PathVariable("paymentId") UUID paymentId,
      @RequestBody @Valid UpdatePaymentRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.updatePayment(paymentId, request, jwtUser);
  }

  @DeleteMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deletePayment(
      @PathVariable UUID paymentId, @AuthenticationPrincipal JwtUser jwtUser) {
    paymentService.deletePaymentById(paymentId, jwtUser);
  }
}
