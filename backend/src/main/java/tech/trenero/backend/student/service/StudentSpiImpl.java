package tech.trenero.backend.student.service;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.spi.StudentSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentSpiImpl implements StudentSpi {
  private final StudentService studentService;

  @Override
  public List<StudentResponse> getStudentsByGroupId(UUID studentId) {
    return studentService.getStudentsByGroupId(studentId);
  }
}
