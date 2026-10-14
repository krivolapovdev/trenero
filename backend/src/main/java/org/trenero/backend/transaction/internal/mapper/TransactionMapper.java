package org.trenero.backend.transaction.internal.mapper;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeParseException;
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

    if (!(response.getPaymentDetails() instanceof StudentPaymentDetailsResponse studentDetails)) {
      return response;
    }

    UUID studentId = studentDetails.getStudentId();
    StudentResponse student = studentsByIds == null ? null : studentsByIds.get(studentId);
    String studentName = student != null ? student.getFullName() : studentDetails.getStudentName();

    StudentPaymentDetailsResponse enrichedDetails =
        new StudentPaymentDetailsResponse(studentId, studentDetails.getPaidUntil(), studentName);

    return new TransactionResponse(
        response.getId(),
        response.getAmount(),
        response.getDate(),
        response.getType(),
        response.getCreatedAt(),
        enrichedDetails);
  }

  @Mapping(target = "id", ignore = true)
  @Mapping(target = "ownerId", source = "ownerId")
  @Mapping(target = "studentPayment", source = "request.paymentDetails")
  Transaction toEntity(CreateTransactionRequest request, UUID ownerId);

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
    if (updates.get("amount") != null) {
      transaction.setAmount(new BigDecimal(updates.get("amount").toString()));
    }

    if (updates.get("date") != null) {
      transaction.setDate(parseDate(updates.get("date")));
    }

    if (updates.get("paidUntil") != null) {
      StudentPayment studentPayment = transaction.getStudentPayment();

      if (studentPayment != null) {
        studentPayment.setPaidUntil(parseDate(updates.get("paidUntil")));
      }
    }

    return transaction;
  }

  default OffsetDateTime parseDate(Object value) {
    if (value == null) {
      return null;
    }

    String text = value.toString().trim();
    if (text.isEmpty()) {
      return null;
    }

    try {
      return OffsetDateTime.parse(text);
    } catch (DateTimeParseException ignored) {
      // Not an offset date time, try the local and plain forms below.
    }

    try {
      return LocalDateTime.parse(text).atOffset(ZoneOffset.UTC);
    } catch (DateTimeParseException ignored) {
      // Not a local date time either, the value is a plain day.
    }

    return LocalDate.parse(text).atStartOfDay(ZoneOffset.UTC).toOffsetDateTime();
  }
}
