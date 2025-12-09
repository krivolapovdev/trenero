package tech.trenero.backend.attendance.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.attendance.internal.entity.Lesson;
import tech.trenero.backend.attendance.internal.entity.StudentAttendance;
import tech.trenero.backend.attendance.internal.request.StudentAttendanceRequest;

@Mapper(componentModel = ComponentModel.SPRING)
public interface StudentAttendanceMapper {
  default StudentAttendance toStudentAttendance(StudentAttendanceRequest request, Lesson lesson) {
    if (request == null || lesson == null) {
      return null;
    }

    StudentAttendance attendance = new StudentAttendance();
    attendance.setLesson(lesson);
    attendance.setStudentId(request.studentId());
    attendance.setPresent(request.present());
    return attendance;
  }
}
