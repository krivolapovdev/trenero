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
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.input.CreatePaymentInput;
import tech.trenero.backend.payment.internal.service.PaymentService;

@Controller
@RequiredArgsConstructor
@Validated
public class PaymentController {
  private final PaymentService paymentService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<PaymentDto> payments(@AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.getAllPayments(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<PaymentDto> payment(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.getPaymentById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public PaymentDto createPayment(
      @Argument("input") @Valid CreatePaymentInput input,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.createPayment(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<PaymentDto> deletePayment(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentService.softDeletePayment(id, jwtUser);
  }
}
