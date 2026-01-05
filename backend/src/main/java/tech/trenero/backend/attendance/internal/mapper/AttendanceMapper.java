package tech.trenero.backend.attendance.internal.mapper;

import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.input.CreateAttendanceInput;

@Mapper(componentModel = ComponentModel.SPRING)
public interface AttendanceMapper {
  AttendanceDto toDto(Attendance attendance);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Attendance toAttendance(CreateAttendanceInput input, UUID ownerId);
}
