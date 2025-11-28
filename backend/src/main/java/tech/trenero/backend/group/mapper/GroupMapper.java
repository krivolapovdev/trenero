package tech.trenero.backend.group.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.group.entity.Group;
import tech.trenero.backend.group.request.GroupRequest;

@Mapper(componentModel = ComponentModel.SPRING)
public interface GroupMapper {
  Group toGroup(GroupRequest groupRequest);

  GroupResponse toGroupResponse(Group group);
}
