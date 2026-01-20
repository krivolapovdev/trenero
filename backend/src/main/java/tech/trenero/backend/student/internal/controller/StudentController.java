package tech.trenero.backend.student.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.internal.request.CreateStudentRequest;
import tech.trenero.backend.student.internal.request.UpdateStudentRequest;
import tech.trenero.backend.student.internal.service.StudentService;

@RestController
@RequestMapping("/api/v1/students")
@RequiredArgsConstructor
@Validated
public class StudentController {
  private final StudentService studentService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<StudentResponse> getStudents(@AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.getAllStudents(jwtUser);
  }

  @GetMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public StudentResponse getStudent(
      @PathVariable UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.getStudentById(id, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public StudentResponse createStudent(
      @RequestBody @Valid CreateStudentRequest request, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.createStudent(request, jwtUser);
  }

  @PatchMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public StudentResponse updateStudent(
      @PathVariable UUID id,
      @RequestBody @Valid UpdateStudentRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return studentService.updateStudent(id, request, jwtUser);
  }

  @DeleteMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteStudent(@PathVariable UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    studentService.softDeleteStudent(id, jwtUser);
  }
}
