package tech.trenero.backend.attendance.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.common.dto.AttendanceDto;

@Mapper(componentModel = ComponentModel.SPRING)
public interface AttendanceMapper {
  AttendanceDto toDto(Attendance attendance);
}
