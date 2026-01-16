package tech.trenero.backend.group.internal.mapper;

import java.util.UUID;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.codegen.types.CreateGroupInput;
import tech.trenero.backend.group.internal.entity.Group;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface GroupMapper {
  tech.trenero.backend.codegen.types.Group toGraphql(Group group);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Group toGroup(CreateGroupInput input, UUID ownerId);

  @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.SET_TO_NULL)
  Group editStudent(@MappingTarget Group group, CreateGroupInput input);
}
