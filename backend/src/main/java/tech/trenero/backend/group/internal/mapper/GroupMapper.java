package tech.trenero.backend.group.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.request.GroupRequest;

@Mapper(componentModel = ComponentModel.SPRING)
public interface GroupMapper {
  Group toGroup(GroupRequest groupRequest);

  GroupResponse toGroupResponse(Group group);
}
