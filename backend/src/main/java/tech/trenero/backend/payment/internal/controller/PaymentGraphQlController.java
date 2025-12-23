package tech.trenero.backend.payment.internal.controller;

import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.input.CreatePaymentInput;
import tech.trenero.backend.payment.internal.service.PaymentGraphQlService;

@Controller
@RequiredArgsConstructor
public class PaymentGraphQlController {
  private final PaymentGraphQlService paymentService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Payment> payment(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.getPaymentById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Payment createPayment(
      @Argument("input") CreatePaymentInput input, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.createPayment(input, jwtUser);
  }
}
