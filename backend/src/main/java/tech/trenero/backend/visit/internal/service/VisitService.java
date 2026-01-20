package tech.trenero.backend.visit.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.visit.external.VisitSpi;
import tech.trenero.backend.visit.internal.entity.Visit;
import tech.trenero.backend.visit.internal.mapper.VisitMapper;
import tech.trenero.backend.visit.internal.repository.VisitRepository;
import tech.trenero.backend.visit.internal.request.CreateVisitRequest;
import tech.trenero.backend.visit.internal.request.UpdateVisitRequest;

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
  public VisitResponse updateVisit(UUID visitId, UpdateVisitRequest request, JwtUser jwtUser) {
    return visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.userId())
        .map(visit -> visitMapper.updateVisit(visit, request))
        .map(this::saveVisit)
        .map(visitMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Visit not found with id: " + visitId));
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

  private Visit saveVisit(Visit visit) {
    log.info("Saving visit: {}", visit);
    return visitRepository.saveAndFlush(visit);
  }

  @Override
  public void removeVisitsByLessonId(UUID lessonId, JwtUser jwtUser) {}
}
