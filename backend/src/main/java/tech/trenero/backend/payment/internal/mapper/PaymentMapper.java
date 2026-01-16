package tech.trenero.backend.payment.internal.mapper;

import java.util.UUID;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;
import tech.trenero.backend.codegen.types.CreatePaymentInput;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.payment.internal.entity.Payment;

@Mapper(componentModel = ComponentModel.SPRING)
public interface PaymentMapper {
  @Mapping(target = "student", source = "studentId", qualifiedByName = "studentFromId")
  tech.trenero.backend.codegen.types.Payment toGraphql(Payment payment);

  @Named("studentFromId")
  default Student studentFromId(UUID studentId) {
    return Student.newBuilder().id(studentId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Payment toPayment(CreatePaymentInput input, UUID ownerId);

  @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.SET_TO_NULL)
  Payment editPayment(@MappingTarget Payment payment, CreatePaymentInput input);
}
