package org.trenero.backend.group.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.common.response.GroupStudentResponse;
import org.trenero.backend.group.internal.domain.GroupStudent;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface GroupStudentMapper {
  GroupStudentResponse toResponse(GroupStudent groupStudent);
}
