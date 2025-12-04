package tech.trenero.backend.student.internal.spi;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.service.StudentService;

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
