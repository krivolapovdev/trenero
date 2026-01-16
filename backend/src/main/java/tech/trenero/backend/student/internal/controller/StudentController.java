package tech.trenero.backend.student.internal.controller;

import graphql.schema.DataFetchingEnvironment;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import tech.trenero.backend.codegen.types.CreateStudentInput;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.codegen.types.UpdateStudentInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.internal.service.StudentService;

@Controller
@RequiredArgsConstructor
@Validated
public class StudentController {
  private final StudentService studentService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<Student> students(@AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.getAllStudents(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Student> student(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.findStudentById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Student createStudent(
      @Argument("input") @Valid CreateStudentInput input,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.createStudent(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Student> updateStudent(
      @Argument("id") UUID id,
      @Argument("input") @Valid UpdateStudentInput input,
      DataFetchingEnvironment environment,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.updateStudent(id, input, environment, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Student> deleteStudent(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.softDeleteStudent(id, jwtUser);
  }
}
