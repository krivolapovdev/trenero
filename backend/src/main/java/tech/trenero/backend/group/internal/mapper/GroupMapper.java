package tech.trenero.backend.group.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.group.internal.entity.Group;

@Mapper(componentModel = ComponentModel.SPRING)
public interface GroupMapper {
  GroupDto toGroupDto(Group group);
}
