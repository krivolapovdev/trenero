package tech.trenero.backend.student.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.PaymentResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.payment.external.PaymentSpi;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.model.Student;
import tech.trenero.backend.student.internal.model.StudentStatus;
import tech.trenero.backend.student.internal.repository.StudentRepository;
import tech.trenero.backend.student.internal.request.CreateStudentRequest;
import tech.trenero.backend.student.internal.request.UpdateStudentRequest;
import tech.trenero.backend.student.internal.response.StudentDetailsResponse;
import tech.trenero.backend.student.internal.response.StudentOverviewResponse;
import tech.trenero.backend.student.internal.response.StudentsOverviewWrapperResponse;
import tech.trenero.backend.student.internal.response.VisitWithLessonResponse;
import tech.trenero.backend.visit.external.VisitSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService implements StudentSpi {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  private final StudentStatusService studentStatusService;

  @Lazy private final StudentService self;
  @Lazy private final GroupSpi groupSpi;
  @Lazy private final PaymentSpi paymentSpi;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public List<StudentResponse> getStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public StudentsOverviewWrapperResponse getStudentsOverview(JwtUser jwtUser) {
    log.info("Getting students overview for ownerId={}", jwtUser.userId());

    List<GroupResponse> allGroups = groupSpi.getAllGroups(jwtUser);

    List<StudentResponse> students = self.getStudents(jwtUser);

    if (students.isEmpty()) {
      return new StudentsOverviewWrapperResponse(List.of(), allGroups);
    }

    List<UUID> groupIds =
        students.stream().map(StudentResponse::groupId).filter(Objects::nonNull).toList();

    List<UUID> studentIds =
        students.stream().filter(Objects::nonNull).map(StudentResponse::id).toList();

    Map<UUID, GroupResponse> groupsMap = groupSpi.getGroupsByIds(groupIds, jwtUser);

    Map<UUID, List<VisitResponse>> visitsMap = visitSpi.getVisitsByStudentIds(studentIds, jwtUser);

    Map<UUID, List<PaymentResponse>> paymentsMap =
        paymentSpi.getPaymentsByStudentIds(studentIds, jwtUser);

    Map<UUID, LessonResponse> lessonMap =
        lessonSpi.getLastGroupLessonsByGroupIds(groupIds, jwtUser);

    List<StudentOverviewResponse> studentOverviewResponses =
        students.stream()
            .map(
                student -> {
                  List<VisitResponse> studentVisits =
                      visitsMap.getOrDefault(student.id(), List.of());

                  List<PaymentResponse> studentPayments =
                      paymentsMap.getOrDefault(student.id(), List.of());

                  LessonResponse lastLesson = lessonMap.get(student.id());

                  Set<StudentStatus> statuses =
                      studentStatusService.getStudentStatuses(
                          studentVisits, studentPayments, lastLesson);

                  GroupResponse group = groupsMap.get(student.groupId());

                  return new StudentOverviewResponse(student, group, statuses);
                })
            .toList();

    return new StudentsOverviewWrapperResponse(studentOverviewResponses, allGroups);
  }

  @Transactional(readOnly = true)
  public StudentResponse getStudentById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student by id={} for ownerId={}", studentId, jwtUser.userId());
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(studentMapper::toResponse)
        .orElseThrow(
            () -> new EntityNotFoundException("Student with id=" + studentId + " not found"));
  }

  @Transactional(readOnly = true)
  public List<StudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting students by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return studentRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<PaymentResponse> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    return paymentSpi.getPaymentsByStudentId(studentId, jwtUser);
  }

  @Transactional(readOnly = true)
  public List<VisitResponse> getVisitsByStudentId(UUID studentId, JwtUser jwtUser) {
    return visitSpi.getVisitsByStudentId(studentId, jwtUser);
  }

  @Transactional(readOnly = true)
  public List<StudentResponse> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting students by ids={} for ownerId={}", studentIds, jwtUser.userId());

    return studentRepository.findAllByIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public StudentDetailsResponse getStudentDetailsById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student details by id={} for ownerId={}", studentId, jwtUser.userId());

    StudentResponse student = self.getStudentById(studentId, jwtUser);

    GroupResponse studentGroup =
        student.groupId() != null ? groupSpi.getGroupById(student.groupId(), jwtUser) : null;
    LessonResponse lastLesson =
        student.groupId() != null ? lessonSpi.getLastGroupLesson(student.groupId(), jwtUser) : null;

    List<VisitResponse> studentVisits = visitSpi.getVisitsByStudentId(studentId, jwtUser);
    List<PaymentResponse> studentPayments = paymentSpi.getPaymentsByStudentId(studentId, jwtUser);
    List<LessonResponse> allLessons = lessonSpi.getLessonsByGroupId(student.groupId(), jwtUser);

    Set<StudentStatus> studentStatuses =
        studentStatusService.getStudentStatuses(studentVisits, studentPayments, lastLesson);

    List<VisitWithLessonResponse> visitsWithLessons =
        studentVisits.stream()
            .map(
                visit ->
                    new VisitWithLessonResponse(
                        visit,
                        allLessons.stream()
                            .filter(lesson -> lesson.id().equals(visit.lessonId()))
                            .findFirst()
                            .orElse(null)))
            .toList();

    return new StudentDetailsResponse(
        student, studentGroup, visitsWithLessons, studentPayments, studentStatuses);
  }

  @Transactional
  public StudentResponse createStudent(CreateStudentRequest request, JwtUser jwtUser) {
    log.info("Creating student: {}", request);

    if (request.groupId() != null) {
      groupSpi.getGroupById(request.groupId(), jwtUser);
    }

    Student student = studentMapper.toStudent(request, jwtUser.userId());

    Student savedStudent = saveStudent(student);

    return studentMapper.toResponse(savedStudent);
  }

  @Transactional
  public void assignGroupToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    log.info(
        "Assign groupId={} to students={} for ownerId={}", groupId, studentIds, jwtUser.userId());

    groupSpi.getGroupById(groupId, jwtUser);

    int updatedCount =
        studentRepository.setGroupIdForStudents(groupId, studentIds, jwtUser.userId());

    log.info("Updated {} students with new groupId={}", updatedCount, groupId);
  }

  @Override
  public void editStudentsGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {}

  @Override
  public void removeGroupFromStudents(UUID groupId, JwtUser jwtUser) {}

  @Override
  public int countStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Counting students by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return studentRepository.countByGroupIdAndOwnerId(groupId, jwtUser.userId());
  }

  @Transactional
  public void removeGroupFromStudents(List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Remove from group from students={} for ownerId={}", studentIds, jwtUser.userId());

    int updatedCount = studentRepository.setGroupIdForStudents(null, studentIds, jwtUser.userId());

    log.info("Updated {} students with empty groupId", updatedCount);
  }

  @Transactional
  public StudentResponse updateStudent(
      UUID studentId, UpdateStudentRequest request, JwtUser jwtUser) {
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(student -> studentMapper.updateStudent(student, request))
        .map(this::saveStudent)
        .map(studentMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Student not found with id=" + studentId));
  }

  @Transactional
  public void softDeleteStudent(UUID studentId, JwtUser jwtUser) {
    log.info("Deleting student: {}", studentId);

    studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(
            student -> {
              student.setDeletedAt(OffsetDateTime.now());
              return saveStudent(student);
            })
        .orElseThrow(() -> new EntityNotFoundException("Student not found with id=" + studentId));
  }

  @Transactional
  public void deleteStudentPayment(UUID paymentId, JwtUser jwtUser) {
    paymentSpi.deletePaymentById(paymentId, jwtUser);
  }

  private Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.saveAndFlush(student);
  }
}
