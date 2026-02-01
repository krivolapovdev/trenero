package tech.trenero.backend.group.internal.mapper;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.GroupStudentResponse;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.group.internal.domain.Group;
import tech.trenero.backend.group.internal.request.CreateGroupRequest;
import tech.trenero.backend.group.internal.response.GroupDetailsResponse;
import tech.trenero.backend.group.internal.response.GroupOverviewResponse;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface GroupMapper {
  GroupResponse toResponse(Group group);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Group toGroup(CreateGroupRequest input, UUID ownerId);

  default Group updateGroup(Group group, Map<String, Object> updates) {
    if (group == null || updates == null) {
      return group;
    }

    if (updates.containsKey("name")) {
      group.setName((String) updates.get("name"));
    }

    if (updates.containsKey("defaultPrice")) {
      Object price = updates.get("defaultPrice");
      group.setDefaultPrice(price != null ? new BigDecimal(price.toString()) : null);
    }

    if (updates.containsKey("note")) {
      group.setNote((String) updates.get("note"));
    }

    return group;
  }

  @Mapping(target = "groupStudents", source = "groupStudents")
  GroupOverviewResponse toGroupOverviewResponse(
      GroupResponse group, List<GroupStudentResponse> groupStudents);

  @Mapping(target = "groupStudents", source = "groupStudents")
  @Mapping(target = "groupLessons", source = "groupLessons")
  GroupDetailsResponse toGroupDetailsResponse(
      GroupResponse group, List<StudentResponse> groupStudents, List<LessonResponse> groupLessons);
}
