package org.trenero.backend.payment.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.common.response.TransactionResponse;
import org.trenero.backend.payment.internal.domain.Transaction;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface TransactionMapper {
  TransactionResponse toResponse(Transaction transaction);
}
