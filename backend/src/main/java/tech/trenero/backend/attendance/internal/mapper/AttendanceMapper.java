package tech.trenero.backend.attendance.internal.mapper;

import static tech.trenero.backend.codegen.DgsConstants.UPDATEATTENDANCEINPUT.Present;

import graphql.schema.DataFetchingEnvironment;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.codegen.types.CreateAttendanceInput;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.codegen.types.UpdateAttendanceInput;

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

  default Attendance updateAttendance(
      Attendance attendance, UpdateAttendanceInput input, DataFetchingEnvironment environment) {
    if (attendance == null || input == null || environment == null) {
      return attendance;
    }

    Map<String, Object> inputMap = environment.getArgument("input");
    if (inputMap == null) {
      return attendance;
    }

    Map<String, Runnable> updates =
        Map.of(Present, () -> attendance.setPresent(input.getPresent()));

    updates.entrySet().stream()
        .filter(entry -> inputMap.containsKey(entry.getKey()))
        .forEach(entry -> entry.getValue().run());

    return attendance;
  }
}
