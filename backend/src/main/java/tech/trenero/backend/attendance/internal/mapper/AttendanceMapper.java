package tech.trenero.backend.attendance.internal.mapper;

import java.util.UUID;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.codegen.types.CreateAttendanceInput;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.codegen.types.Student;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface AttendanceMapper {
  @Mapping(target = "lesson", source = "lessonId", qualifiedByName = "lessonFromId")
  @Mapping(target = "student", source = "studentId", qualifiedByName = "studentFromId")
  tech.trenero.backend.codegen.types.Attendance toGraphql(Attendance attendance);

  @Named("lessonFromId")
  default Lesson lessonFromId(UUID lessonId) {
    return Lesson.newBuilder().id(lessonId).build();
  }

  @Named("studentFromId")
  default Student studentFromId(UUID studentId) {
    return Student.newBuilder().id(studentId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Attendance toAttendance(CreateAttendanceInput input, UUID ownerId);

  @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.SET_TO_NULL)
  Attendance editAttendance(@MappingTarget Attendance attendance, CreateAttendanceInput input);
}
