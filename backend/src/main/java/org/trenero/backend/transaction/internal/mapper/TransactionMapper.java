package org.trenero.backend.transaction.internal.mapper;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;
import lombok.NonNull;
import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.transaction.internal.domain.StudentPayment;
import org.trenero.backend.transaction.internal.domain.Transaction;
import org.trenero.backend.transaction.internal.request.CreatePaymentDetailsRequest;
import org.trenero.backend.transaction.internal.request.CreateStudentPaymentDetailsRequest;
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface TransactionMapper {

  @Mapping(target = "paymentDetails", source = "studentPayment")
  TransactionResponse toResponse(Transaction transaction);

  StudentPaymentDetailsResponse toStudentPaymentDetailsResponse(StudentPayment studentPayment);

  default TransactionResponse toResponse(
      Transaction transaction, Map<UUID, StudentResponse> studentsByIds) {
    if (transaction == null) {
      return null;
    }

    TransactionResponse response = toResponse(transaction);

    if (response.getPaymentDetails() instanceof StudentPaymentDetailsResponse studentDetails
        && studentsByIds != null) {
      StudentPaymentDetailsResponse enrichedDetails =
          new StudentPaymentDetailsResponse(
              studentDetails.getStudentId(),
              studentDetails.getPaidUntil(),
              studentDetails.getStudentName());

      return new TransactionResponse(
          response.getId(),
          response.getAmount(),
          response.getDate(),
          response.getType(),
          response.getCreatedAt(),
          enrichedDetails);
    }

    return response;
  }

  @Mapping(target = "id", ignore = true)
  @Mapping(target = "ownerId", source = "ownerId")
  @Mapping(target = "studentPayment", source = "request.paymentDetails")
  Transaction toEntity(CreateTransactionRequest request, UUID ownerId);

  /**
   * Maps the polymorphic payment details of a transaction request. MapStruct cannot derive this
   * mapping from the sealed {@link CreatePaymentDetailsRequest} on its own.
   */
  default StudentPayment toStudentPayment(CreatePaymentDetailsRequest details) {
    if (details instanceof CreateStudentPaymentDetailsRequest studentDetails) {
      return StudentPayment.builder()
          .studentId(studentDetails.getStudentId())
          .paidUntil(studentDetails.getPaidUntil())
          .build();
    }

    return null;
  }

  @AfterMapping
  default void linkStudentPayment(@MappingTarget Transaction transaction) {
    if (transaction.getStudentPayment() != null) {
      transaction.getStudentPayment().setTransaction(transaction);
    }
  }

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
