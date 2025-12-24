package tech.trenero.backend.attendance.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.attendance.internal.request.StudentAttendanceRequest;

@Mapper(componentModel = ComponentModel.SPRING)
public interface AttendanceMapper {
  default Attendance toStudentAttendance(StudentAttendanceRequest request) {
    if (request == null) {
      return null;
    }

    Attendance attendance = new Attendance();
    attendance.setStudentId(request.studentId());
    attendance.setPresent(request.present());
    return attendance;
  }
}
