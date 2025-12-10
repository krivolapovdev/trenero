package tech.trenero.backend.payment.internal.mapper;

import java.time.LocalDateTime;
import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.request.PaymentRequest;
import tech.trenero.backend.payment.internal.response.PaymentResponse;

@Mapper(componentModel = ComponentModel.SPRING)
public interface PaymentMapper {
  PaymentResponse toPaymentResponse(Payment payment);

  default Payment toPayment(PaymentRequest request) {
    if (request == null) {
      return null;
    }

    Payment payment = new Payment();
    payment.setStudentId(request.studentId());
    payment.setAmount(request.amount());
    payment.setCreatedAt(LocalDateTime.now());

    return payment;
  }
}
