package tech.trenero.backend.group.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.request.CreateGroupRequest;

@Mapper(componentModel = ComponentModel.SPRING)
public interface GroupMapper {
  Group toGroup(CreateGroupRequest createGroupRequest);

  GroupResponse toGroupResponse(Group group);

  GroupDto toGroupDto(Group group);
}
