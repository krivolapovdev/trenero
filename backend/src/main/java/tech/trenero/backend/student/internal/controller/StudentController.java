package tech.trenero.backend.student.internal.controller;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.request.CreateStudentInput;
import tech.trenero.backend.student.internal.service.StudentGraphQlService;

@Controller
@RequiredArgsConstructor
public class StudentController {
  private final StudentGraphQlService studentService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<Student> students(@AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.getAllStudents(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Student student(@Argument UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.getStudentById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Student createStudent(
      @Argument CreateStudentInput input, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.createStudent(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Student deleteStudent(@Argument UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.softDeleteStudent(id, jwtUser);
  }
}
