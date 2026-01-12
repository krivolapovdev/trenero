package tech.trenero.backend.group.internal.mapper;

import java.util.UUID;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.input.CreateGroupInput;

@Mapper(componentModel = ComponentModel.SPRING)
public interface GroupMapper {
  GroupDto toGroupDto(Group group);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Group toGroup(CreateGroupInput input, UUID ownerId);

  @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.SET_TO_NULL)
  Group editStudent(@MappingTarget Group group, CreateGroupInput input);
}
