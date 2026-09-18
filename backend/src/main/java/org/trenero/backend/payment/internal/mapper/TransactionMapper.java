package org.trenero.backend.payment.internal.mapper;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;
import lombok.NonNull;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.common.response.TransactionResponse;
import org.trenero.backend.payment.internal.domain.Transaction;
import org.trenero.backend.payment.internal.request.CreateTransactionRequest;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface TransactionMapper {

  TransactionResponse toResponse(Transaction transaction);

  @Mapping(target = "id", ignore = true)
  @Mapping(target = "ownerId", source = "ownerId")
  Transaction toEntity(CreateTransactionRequest request, UUID ownerId);

  default @NonNull Transaction updateTransaction(
      @NonNull Transaction transaction, @NonNull Map<String, Object> updates) {
    if (updates.containsKey("amount")) {
      Object amount = updates.get("amount");
      transaction.setAmount(amount != null ? new BigDecimal(amount.toString()) : null);
    }

    if (updates.containsKey("date")) {
      Object date = updates.get("date");
      transaction.setDate(date != null ? LocalDate.parse(date.toString()) : null);
    }

    return transaction;
  }
}
