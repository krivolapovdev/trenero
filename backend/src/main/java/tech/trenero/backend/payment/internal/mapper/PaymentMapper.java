package tech.trenero.backend.payment.internal.mapper;

import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.common.response.PaymentResponse;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.request.CreatePaymentRequest;
import tech.trenero.backend.payment.internal.request.UpdatePaymentRequest;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface PaymentMapper {
  PaymentResponse toResponse(Payment payment);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Payment toPayment(CreatePaymentRequest request, UUID ownerId);

  default Payment updatePayment(Payment payment, UpdatePaymentRequest request) {
    if (payment == null || request == null) {
      return payment;
    }

    return payment;
  }
}
