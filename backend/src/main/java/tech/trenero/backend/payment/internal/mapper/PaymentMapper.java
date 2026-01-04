package tech.trenero.backend.payment.internal.mapper;

import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.input.CreatePaymentInput;

@Mapper(componentModel = ComponentModel.SPRING)
public interface PaymentMapper {
  PaymentDto toPaymentDto(Payment payment);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Payment toPayment(CreatePaymentInput input, UUID ownerId);
}
