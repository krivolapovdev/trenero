package tech.trenero.backend.student.internal.controller;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.internal.request.StudentRequest;
import tech.trenero.backend.student.internal.response.StudentWithGroupsResponse;
import tech.trenero.backend.student.internal.service.StudentService;

@RestController
@RequestMapping("/api/v1/students")
@RequiredArgsConstructor
@Validated
public class StudentController {
  private final StudentService studentService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<StudentResponse> getAllStudents(@AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.getAllStudents(jwtUser);
  }

  @GetMapping("/{studentId}")
  @PreAuthorize("isAuthenticated()")
  public StudentWithGroupsResponse getStudentWithGroupsById(
      @PathVariable UUID studentId, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.getStudentWithGroupsById(studentId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  public UUID createStudent(
      @RequestBody StudentRequest studentRequest, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.createStudent(studentRequest, jwtUser);
  }

  @DeleteMapping("/{studentId}")
  @PreAuthorize("isAuthenticated()")
  public void deleteStudent(
      @PathVariable UUID studentId, @AuthenticationPrincipal JwtUser jwtUser) {
    studentService.softDeleteStudent(studentId, jwtUser);
  }
}
