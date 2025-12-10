package tech.trenero.backend.payment.internal.controller;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.request.PaymentRequest;
import tech.trenero.backend.payment.internal.response.PaymentResponse;
import tech.trenero.backend.payment.internal.service.PaymentService;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Validated
public class PaymentController {
  private final PaymentService paymentService;

  @GetMapping("/{paymentId}")
  @PreAuthorize("isAuthenticated()")
  public PaymentResponse getPaymentById(
      @PathVariable UUID paymentId, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.getPaymentById(paymentId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  public UUID addPayment(
      @RequestBody PaymentRequest paymentRequest, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.createPayment(paymentRequest, jwtUser);
  }
}
