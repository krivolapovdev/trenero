package tech.trenero.backend.student.internal.spi;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.service.StudentGraphQlService;
import tech.trenero.backend.student.internal.service.StudentService;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentSpiImpl implements StudentSpi {
  private final StudentService studentService;
  private final StudentGraphQlService studentGraphQlService;
  private final StudentMapper studentMapper;

  @Override
  public StudentResponse getStudentById(UUID studentId, JwtUser jwtUser) {
    return studentService.getStudentById(studentId, jwtUser);
  }

  @Override
  public List<StudentDto> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    return studentGraphQlService.getStudentsByGroupId(groupId, jwtUser).stream()
        .map(studentMapper::toStudentDto)
        .toList();
  }
}
