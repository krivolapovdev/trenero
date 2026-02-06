package org.trenero.backend.payment.internal.mapper;

import java.time.LocalDate;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.common.response.StudentPaymentResponse;
import org.trenero.backend.common.response.TransactionResponse;
import org.trenero.backend.payment.internal.domain.StudentPayment;
import org.trenero.backend.payment.internal.domain.Transaction;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface StudentPaymentMapper {
  @Mapping(target = "id", source = "payment.transactionId")
  @Mapping(target = "studentId", source = "payment.studentId")
  @Mapping(target = "paidUntil", source = "payment.paidUntil")
  @Mapping(target = "paidFrom", source = "paidFrom")
  @Mapping(target = "amount", source = "tx.amount")
  @Mapping(target = "date", source = "tx.date")
  @Mapping(target = "createdAt", source = "tx.createdAt")
  StudentPaymentResponse toResponse(StudentPayment payment, Transaction tx, LocalDate paidFrom);

  @Mapping(target = "id", source = "payment.transactionId")
  @Mapping(target = "studentId", source = "payment.studentId")
  @Mapping(target = "paidUntil", source = "payment.paidUntil")
  @Mapping(target = "paidFrom", source = "paidFrom")
  @Mapping(target = "amount", source = "tx.amount")
  @Mapping(target = "date", source = "tx.date")
  @Mapping(target = "createdAt", source = "tx.createdAt")
  StudentPaymentResponse toResponse(
      StudentPayment payment, TransactionResponse tx, LocalDate paidFrom);
}
