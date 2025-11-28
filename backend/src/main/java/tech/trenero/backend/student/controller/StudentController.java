package tech.trenero.backend.student.controller;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.student.request.StudentRequest;
import tech.trenero.backend.student.response.StudentResponse;
import tech.trenero.backend.student.service.StudentService;

@RestController
@RequestMapping("/api/v1/students")
@RequiredArgsConstructor
@Validated
public class StudentController {
  private final StudentService studentService;

  @GetMapping("/{id}")
  public StudentResponse getStudentById(@PathVariable UUID id) {
    return studentService.getStudentById(id);
  }

  @PostMapping
  public UUID createStudent(@RequestBody StudentRequest studentRequest) {
    return studentService.createStudent(studentRequest);
  }
}
