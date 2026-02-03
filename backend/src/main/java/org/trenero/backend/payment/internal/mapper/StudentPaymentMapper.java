package org.trenero.backend.payment.internal.mapper;

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
  StudentPaymentResponse toResponse(StudentPayment studentPayment);

  @Mapping(target = "id", source = "payment.transactionId")
  @Mapping(target = "studentId", source = "payment.studentId")
  @Mapping(target = "paidLessons", source = "payment.paidLessons")
  @Mapping(target = "amount", source = "tx.amount")
  @Mapping(target = "date", source = "tx.date")
  @Mapping(target = "createdAt", source = "tx.createdAt")
  StudentPaymentResponse toResponse(StudentPayment payment, Transaction tx);

  @Mapping(target = "id", source = "payment.transactionId")
  @Mapping(target = "studentId", source = "payment.studentId")
  @Mapping(target = "paidLessons", source = "payment.paidLessons")
  @Mapping(target = "amount", source = "tx.amount")
  @Mapping(target = "date", source = "tx.date")
  @Mapping(target = "createdAt", source = "tx.createdAt")
  StudentPaymentResponse toResponse(StudentPayment payment, TransactionResponse tx);
}
