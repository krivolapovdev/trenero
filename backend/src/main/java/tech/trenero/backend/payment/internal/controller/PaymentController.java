package tech.trenero.backend.payment.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import tech.trenero.backend.codegen.types.CreatePaymentInput;
import tech.trenero.backend.codegen.types.Payment;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.service.PaymentService;

@Controller
@RequiredArgsConstructor
@Validated
public class PaymentController {
  private final PaymentService paymentService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<Payment> payments(@AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.getAllPayments(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Payment> payment(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.findPaymentById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Payment createPayment(
      @Argument("input") @Valid CreatePaymentInput input,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.createPayment(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Payment> editPayment(
      @Argument("id") UUID id,
      @Argument("input") @Valid CreatePaymentInput input,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.editPayment(id, input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Payment> deletePayment(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.softDeletePayment(id, jwtUser);
  }
}
