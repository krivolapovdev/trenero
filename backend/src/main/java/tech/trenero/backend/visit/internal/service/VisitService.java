package tech.trenero.backend.visit.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.domain.StudentVisit;
import tech.trenero.backend.common.request.CreateVisitRequest;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.visit.external.VisitSpi;
import tech.trenero.backend.visit.internal.domain.Visit;
import tech.trenero.backend.visit.internal.mapper.VisitMapper;
import tech.trenero.backend.visit.internal.repository.VisitRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class VisitService implements VisitSpi {
  private final VisitRepository visitRepository;
  private final VisitMapper visitMapper;

  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public List<VisitResponse> getAllVisits(JwtUser jwtUser) {
    log.info("Getting all visits for ownerId={}", jwtUser.userId());
    return visitRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public VisitResponse getVisitById(UUID visitId, JwtUser jwtUser) {
    log.info("Getting visit by id={} for ownerId={}", visitId, jwtUser.userId());
    return visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.userId())
        .map(visitMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Visit not found with id: " + visitId));
  }

  @Transactional(readOnly = true)
  public List<VisitResponse> getVisitsByLessonId(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting visits by lessonId={} for ownerId={}", lessonId, jwtUser.userId());
    return visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.userId()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Override
  public Map<UUID, List<VisitResponse>> getVisitsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting visits by studentIds for ownerId={}", jwtUser.userId());

    return visitRepository.findAllByStudentIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(visitMapper::toResponse)
        .collect(Collectors.groupingBy(VisitResponse::studentId));
  }

  @Override
  @Transactional(readOnly = true)
  public VisitResponse getVisitByLessonIdAndStudentId(
      UUID lessonId, UUID studentId, JwtUser jwtUser) {
    log.info("Getting visit by lessonId={} and studentId={}", lessonId, studentId);
    return visitRepository
        .findByLessonIdAndStudentIdAndOwnerId(lessonId, studentId, jwtUser.userId())
        .map(visitMapper::toResponse)
        .orElseThrow(
            () ->
                new EntityNotFoundException(
                    "Visit not found for lessonId=" + lessonId + "  and studentId=" + studentId));
  }

  @Transactional(readOnly = true)
  public List<VisitResponse> getVisitsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting visits by studentId={} for ownerId={}", studentId, jwtUser.userId());
    return visitRepository.findAllByStudentIdAndOwnerId(studentId, jwtUser.userId()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Transactional
  public VisitResponse createVisit(CreateVisitRequest request, JwtUser jwtUser) {
    log.info(
        "Creating visit for lessonId='{}', studentId='{}', present={}, ownerId={}",
        request.lessonId(),
        request.studentId(),
        request.present(),
        jwtUser.userId());

    lessonSpi.getLessonById(request.lessonId(), jwtUser);

    Visit visit = visitMapper.toVisit(request, jwtUser.userId());

    Visit savedVisit = saveVisit(visit);

    return visitMapper.toResponse(savedVisit);
  }

  @Transactional
  public VisitResponse updateVisit(UUID visitId, Map<String, Object> request, JwtUser jwtUser) {
    return visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.userId())
        .map(visit -> visitMapper.updateVisit(visit, request))
        .map(this::saveVisit)
        .map(visitMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Visit not found with id: " + visitId));
  }

  @Override
  public void createVisits(UUID lessonId, List<StudentVisit> studentVisitList, JwtUser jwtUser) {
    UUID ownerId = jwtUser.userId();

    log.info(
        "Initializing attendance snapshot for lessonId='{}', participants count={}, ownerId={}",
        lessonId,
        studentVisitList.size(),
        ownerId);

    List<Visit> visits =
        studentVisitList.stream()
            .map(
                sv ->
                    Visit.builder()
                        .ownerId(ownerId)
                        .lessonId(lessonId)
                        .studentId(sv.studentId())
                        .status(sv.status())
                        .build())
            .toList();

    visitRepository.saveAllAndFlush(visits);
  }

  @Transactional
  public void softDeleteVisit(UUID visitId, JwtUser jwtUser) {
    log.info("Soft deleting visit: {}", visitId);
    visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.userId())
        .map(
            visit -> {
              visit.setDeletedAt(OffsetDateTime.now());
              return saveVisit(visit);
            })
        .orElseThrow(() -> new EntityNotFoundException("Visit not found with id: " + visitId));
  }

  @Transactional
  public void saveVisitList(List<Visit> visitList) {
    log.info("Saving visit list: {}", visitList);
    visitRepository.saveAllAndFlush(visitList);
  }

  @Override
  @Transactional
  public void removeVisitsByLessonId(UUID lessonId, JwtUser jwtUser) {
    log.info(
        "Removing (soft delete) all visits for lessonId={} for ownerId={}",
        lessonId,
        jwtUser.userId());

    List<Visit> visits = visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.userId());

    OffsetDateTime now = OffsetDateTime.now();

    visits.forEach(visit -> visit.setDeletedAt(now));

    visitRepository.saveAllAndFlush(visits);
  }

  @Override
  @Transactional
  public void updateVisitsByLessonId(UUID lessonId, List<StudentVisit> requests, JwtUser jwtUser) {
    log.info("Updating visits for lessonId={} for ownerId={}", lessonId, jwtUser.userId());

    List<Visit> lessonVisits =
        visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.userId());

    Map<UUID, Visit> studentVisitMap =
        lessonVisits.stream().collect(Collectors.toMap(Visit::getStudentId, Function.identity()));

    Set<UUID> incomingStudentIds =
        requests.stream().map(StudentVisit::studentId).collect(Collectors.toSet());

    requests.forEach(
        req -> {
          if (studentVisitMap.containsKey(req.studentId())) {
            Visit visit = studentVisitMap.get(req.studentId());
            visit.setStatus(req.status());
          } else {
            Visit newVisit =
                Visit.builder()
                    .ownerId(jwtUser.userId())
                    .lessonId(lessonId)
                    .studentId(req.studentId())
                    .status(req.status())
                    .build();
            lessonVisits.add(newVisit);
          }
        });

    lessonVisits.stream()
        .filter(visit -> !incomingStudentIds.contains(visit.getStudentId()))
        .forEach(visit -> visit.setDeletedAt(OffsetDateTime.now()));

    visitRepository.saveAllAndFlush(lessonVisits);
  }

  private Visit saveVisit(Visit visit) {
    log.info("Saving visit: {}", visit);
    return visitRepository.saveAndFlush(visit);
  }
}
