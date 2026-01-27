package tech.trenero.backend.group.internal.mapper;

import java.util.List;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.request.CreateGroupRequest;
import tech.trenero.backend.group.internal.request.UpdateGroupRequest;
import tech.trenero.backend.group.internal.response.GroupDetailsResponse;
import tech.trenero.backend.group.internal.response.GroupOverviewResponse;
import tech.trenero.backend.group.internal.response.GroupUpdateDetailsResponse;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface GroupMapper {
  GroupResponse toResponse(Group group);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Group toGroup(CreateGroupRequest input, UUID ownerId);

  default Group updateGroup(Group group, UpdateGroupRequest request) {
    if (group == null || request == null) {
      return group;
    }

    request.name().ifPresent(group::setName);
    request.defaultPrice().ifPresent(group::setDefaultPrice);
    request.note().ifPresent(group::setNote);

    return group;
  }

  @Mapping(target = "studentsCount", source = "studentsCount")
  GroupOverviewResponse toGroupOverviewResponse(GroupResponse group, int studentsCount);

  @Mapping(target = "groupStudents", source = "groupStudents")
  @Mapping(target = "groupLessons", source = "groupLessons")
  GroupDetailsResponse toGroupDetailsResponse(
      GroupResponse group, List<StudentResponse> groupStudents, List<LessonResponse> groupLessons);

  @Mapping(target = "groupStudents", source = "groupStudents")
  @Mapping(target = "allStudents", source = "allStudents")
  GroupUpdateDetailsResponse toGroupUpdateDetailsResponse(
      GroupResponse group, List<StudentResponse> groupStudents, List<StudentResponse> allStudents);
}
