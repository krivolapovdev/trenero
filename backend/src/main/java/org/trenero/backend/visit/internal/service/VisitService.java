package org.trenero.backend.visit.internal.service;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.StudentVisit;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.external.spi.VisitSpi;
import org.trenero.backend.visit.internal.domain.Visit;
import org.trenero.backend.visit.internal.mapper.VisitMapper;
import org.trenero.backend.visit.internal.repository.VisitRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class VisitService implements VisitSpi {

  private final VisitRepository visitRepository;
  private final VisitMapper visitMapper;

  @Transactional(readOnly = true)
  public @NonNull List<VisitResponse> getVisitsByLessonId(
      @NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    log.info("Getting visits by lesson id: lessonId={}; user={}", lessonId, jwtUser);
    return visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.id()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, List<VisitResponse>> getVisitsByStudentIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting visits by student ids: studentIds={}; user={}", studentIds, jwtUser);
    return visitRepository.findAllByStudentIdsAndOwnerId(studentIds, jwtUser.id()).stream()
        .map(visitMapper::toResponse)
        .collect(Collectors.groupingBy(VisitResponse::getStudentId));
  }

  @Transactional(readOnly = true)
  public @NonNull List<VisitResponse> getVisitsByStudentId(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting visits by student id: studentId={}; user={}", studentId, jwtUser);
    return visitRepository.findAllByStudentIdAndOwnerId(studentId, jwtUser.id()).stream()
        .map(visitMapper::toResponse)
        .toList();
  }

  @Override
  @Transactional
  public void createVisits(
      @NonNull UUID lessonId,
      @NonNull List<StudentVisit> studentVisitList,
      @NonNull JwtUser jwtUser) {
    log.info(
        "Creating multiple visits: lessonId={}; participantsCount={}; user={}",
        lessonId,
        studentVisitList.size(),
        jwtUser);

    var visits =
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

  @Override
  @Transactional
  public void removeVisitsByLessonId(@NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    log.info("Removing visits by lesson id: lessonId={}; user={}", lessonId, jwtUser);

    var visits = visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.id());

    visitRepository.deleteAll(visits);
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

    List<Visit> visitsToDelete =
        lessonVisits.stream()
            .filter(visit -> !incomingStudentIds.contains(visit.getStudentId()))
            .toList();

    visitRepository.deleteAll(visitsToDelete);

    List<Visit> visitsToSave =
        lessonVisits.stream()
            .filter(visit -> incomingStudentIds.contains(visit.getStudentId()))
            .toList();

    visitRepository.saveAllAndFlush(visitsToSave);
  }
}
