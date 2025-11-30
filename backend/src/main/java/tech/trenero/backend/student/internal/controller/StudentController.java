package tech.trenero.backend.student.internal.controller;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.student.internal.request.StudentRequest;
import tech.trenero.backend.student.internal.response.StudentWithGroupsResponse;
import tech.trenero.backend.student.internal.service.StudentService;

@RestController
@RequestMapping("/api/v1/students")
@RequiredArgsConstructor
@Validated
public class StudentController {
  private final StudentService studentService;

  @GetMapping("/{id}")
  public StudentWithGroupsResponse getStudentById(@PathVariable UUID id) {
    return studentService.getStudentById(id);
  }

  @PostMapping
  public UUID createStudent(@RequestBody StudentRequest studentRequest) {
    return studentService.createStudent(studentRequest);
  }
}
