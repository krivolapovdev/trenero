package tech.trenero.backend.payment.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.payment.internal.entity.Payment;

@Mapper(componentModel = ComponentModel.SPRING)
public interface PaymentMapper {
  PaymentDto toPaymentDto(Payment payment);
}
