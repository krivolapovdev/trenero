package tech.trenero.backend.payment.internal.mapper;

import graphql.schema.DataFetchingEnvironment;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.codegen.types.CreatePaymentInput;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.codegen.types.UpdatePaymentInput;
import tech.trenero.backend.payment.internal.entity.Payment;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface PaymentMapper {
  @Mapping(target = "student", source = "studentId", qualifiedByName = "studentFromId")
  tech.trenero.backend.codegen.types.Payment toGraphql(Payment payment);

  @Named("studentFromId")
  default Student studentFromId(UUID studentId) {
    return Student.newBuilder().id(studentId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Payment toPayment(CreatePaymentInput input, UUID ownerId);

  default Payment updatePayment(
      Payment payment, UpdatePaymentInput input, DataFetchingEnvironment environment) {
    if (payment == null || input == null || environment == null) {
      return payment;
    }

    Map<String, Object> inputMap = environment.getArgument("input");
    if (inputMap == null) {
      return payment;
    }

    Map<String, Runnable> updates =
        Map.of(
            "amount", () -> payment.setAmount(input.getAmount()),
            "lessonsPerPayment", () -> payment.setLessonsPerPayment(input.getLessonsPerPayment()),
            "date", () -> payment.setDate(input.getDate()));

    updates.entrySet().stream()
        .filter(entry -> inputMap.containsKey(entry.getKey()))
        .forEach(entry -> entry.getValue().run());

    return payment;
  }
}
