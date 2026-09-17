package org.trenero.backend.visit.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.StudentVisit;
import org.trenero.backend.common.request.CreateVisitRequest;
import org.trenero.backend.common.response.VisitResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.lesson.external.LessonSpi;
import org.trenero.backend.visit.external.VisitSpi;
import org.trenero.backend.visit.internal.domain.Visit;
import org.trenero.backend.visit.internal.mapper.VisitMapper;
import org.trenero.backend.visit.internal.repository.VisitRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class VisitService implements VisitSpi {

  private final VisitRepository visitRepository;
  private final VisitMapper visitMapper;

  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public @NonNull List<VisitResponse> getAllVisits(@NonNull JwtUser jwtUser) {
    log.info("Fetching all visits for userId={}", jwtUser.id());
    return visitRepository.findAllByOwnerId(jwtUser.id()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull VisitResponse getVisitById(@NonNull UUID visitId, @NonNull JwtUser jwtUser) {
    log.info("Getting visit by id: visitId={}; user={}", visitId, jwtUser);
    return visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.id())
        .map(visitMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Visit.class, visitId, jwtUser));
  }

  @Transactional(readOnly = true)
  public @NonNull List<VisitResponse> getVisitsByLessonId(
      @NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    log.info("Getting visits by lesson id: lessonId={}; user={}", lessonId, jwtUser);
    return visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.id()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Override
  public @NonNull Map<UUID, List<VisitResponse>> getVisitsByStudentIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting visits by student ids: studentIds={}; user={}", studentIds, jwtUser);
    return visitRepository.findAllByStudentIdsAndOwnerId(studentIds, jwtUser.id()).stream()
        .map(visitMapper::toResponse)
        .collect(Collectors.groupingBy(VisitResponse::studentId));
  }

  @Transactional(readOnly = true)
  public @NonNull List<VisitResponse> getVisitsByStudentId(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting visits by student id: studentId={}; user={}", studentId, jwtUser);
    return visitRepository.findAllByStudentIdAndOwnerId(studentId, jwtUser.id()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Transactional
  public @NonNull VisitResponse createVisit(
      @NonNull CreateVisitRequest request, @NonNull JwtUser jwtUser) {
    log.info("Creating visit: request={}; user={}", request, jwtUser);

    lessonSpi.getLessonById(request.lessonId(), jwtUser);

    Visit visit = visitMapper.toVisit(request, jwtUser.id());

    Visit savedVisit = saveVisit(visit);

    return visitMapper.toResponse(savedVisit);
  }

  @Transactional
  public VisitResponse updateVisit(UUID visitId, Map<String, Object> request, JwtUser jwtUser) {
    log.info("Updating visit: visitId={}; request={}; user={}", visitId, request, jwtUser);
    return visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.id())
        .map(visit -> visitMapper.updateVisit(visit, request))
        .map(this::saveVisit)
        .map(visitMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Visit.class, visitId, jwtUser));
  }

  @Override
  public void createVisits(
      @NonNull UUID lessonId,
      @NonNull List<StudentVisit> studentVisitList,
      @NonNull JwtUser jwtUser) {
    log.info(
        "Creating multiple visits: lessonId={}; participantsCount={}; user={}",
        lessonId,
        studentVisitList.size(),
        jwtUser);

    List<Visit> visits =
        studentVisitList.stream()
            .map(
                sv ->
                    Visit.builder()
                        .ownerId(jwtUser.id())
                        .lessonId(lessonId)
                        .studentId(sv.studentId())
                        .status(sv.status())
                        .type(sv.type())
                        .build())
            .toList();

    visitRepository.saveAllAndFlush(visits);
  }

  @Transactional
  public void softDeleteVisit(UUID visitId, JwtUser jwtUser) {
    log.info("Deleting visit: visitId={}; user={}", visitId, jwtUser);
    visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.id())
        .map(
            visit -> {
              visit.setDeletedAt(OffsetDateTime.now());
              return saveVisit(visit);
            })
        .orElseThrow(entityNotFoundSupplier(Visit.class, visitId, jwtUser));
  }

  @Override
  @Transactional
  public void removeVisitsByLessonId(@NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    log.info("Removing visits by lesson id: lessonId={}; user={}", lessonId, jwtUser);

    List<Visit> visits = visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.id());

    OffsetDateTime now = OffsetDateTime.now();

    visits.forEach(visit -> visit.setDeletedAt(now));

    visitRepository.saveAllAndFlush(visits);
  }

  @Override
  @Transactional
  public void updateVisitsByLessonId(
      @NonNull UUID lessonId, @NonNull List<StudentVisit> requests, @NonNull JwtUser jwtUser) {
    log.info("Updating visits by lesson id: lessonId={}; user={}", lessonId, jwtUser);

    List<Visit> lessonVisits = visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.id());

    Map<UUID, Visit> studentVisitMap =
        lessonVisits.stream().collect(Collectors.toMap(Visit::getStudentId, Function.identity()));

    Set<UUID> incomingStudentIds =
        requests.stream().map(StudentVisit::studentId).collect(Collectors.toSet());

    requests.forEach(
        req -> {
          if (studentVisitMap.containsKey(req.studentId())) {
            Visit visit = studentVisitMap.get(req.studentId());
            visit.setStatus(req.status());
            visit.setType(req.type());
          } else {
            Visit newVisit =
                Visit.builder()
                    .ownerId(jwtUser.id())
                    .lessonId(lessonId)
                    .studentId(req.studentId())
                    .status(req.status())
                    .type(req.type())
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
    log.info("Saving visit: visit={}", visit);
    return visitRepository.saveAndFlush(visit);
  }
}
