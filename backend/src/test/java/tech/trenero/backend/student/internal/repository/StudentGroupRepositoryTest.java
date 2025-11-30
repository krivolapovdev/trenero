package tech.trenero.backend.student.internal.repository;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import tech.trenero.backend.TestcontainersConfig;
import tech.trenero.backend.student.internal.entity.StudentGroup;
import tech.trenero.backend.student.internal.entity.StudentGroup.StudentGroupId;

@DataJpaTest
@Import(TestcontainersConfig.class)
class StudentGroupRepositoryTest {
  @Autowired private StudentGroupRepository studentGroupRepository;

  @Test
  void shouldSaveAndLoadEntity() {
    UUID studentId = UUID.randomUUID();
    UUID groupId = UUID.randomUUID();
    var group = new StudentGroup(studentId, groupId);
    studentGroupRepository.save(group);

    StudentGroupId studentGroupId = new StudentGroupId(studentId, groupId);
    Optional<StudentGroup> loaded = studentGroupRepository.findById(studentGroupId);
    assertThat(loaded).isPresent();
    assertThat(loaded.get().getStudentId()).isEqualTo(studentId);
    assertThat(loaded.get().getGroupId()).isEqualTo(groupId);
  }
}
