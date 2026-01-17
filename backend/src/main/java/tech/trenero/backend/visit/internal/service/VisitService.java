package tech.trenero.backend.visit.internal.service;

import graphql.schema.DataFetchingEnvironment;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.codegen.types.CreateVisitInput;
import tech.trenero.backend.codegen.types.UpdateVisitInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.visit.internal.entity.Visit;
import tech.trenero.backend.visit.internal.mapper.VisitMapper;
import tech.trenero.backend.visit.internal.repository.VisitRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class VisitService {
  private final VisitRepository visitRepository;
  private final VisitMapper visitMapper;
  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Visit> getAllVisits(JwtUser jwtUser) {
    log.info("Getting all visits for ownerId={}", jwtUser.userId());
    return visitRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(visitMapper::toGraphql)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<tech.trenero.backend.codegen.types.Visit> findVisitById(
      UUID visitId, JwtUser jwtUser) {
    log.info("Getting visit by id={} for ownerId={}", visitId, jwtUser.userId());
    return visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.userId())
        .map(visitMapper::toGraphql);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Visit> getVisitsByLessonId(
      UUID lessonId, JwtUser jwtUser) {
    log.info("Getting visits by lessonId={} for ownerId={}", lessonId, jwtUser.userId());
    return visitRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.userId()).stream()
        .map(visitMapper::toGraphql)
        .toList();
  }

  @Transactional
  public tech.trenero.backend.codegen.types.Visit createVisit(
      CreateVisitInput input, JwtUser jwtUser) {
    log.info(
        "Creating visit for lessonId='{}', studentId='{}', present={}, ownerId={}",
        input.getLessonId(),
        input.getStudentId(),
        input.getPresent(),
        jwtUser.userId());

    lessonSpi.getLessonById(input.getLessonId(), jwtUser);

    Visit visit = visitMapper.toVisit(input, jwtUser.userId());

    Visit savedVisit = saveVisit(visit);

    return visitMapper.toGraphql(savedVisit);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Visit> updateVisit(
      UUID id, UpdateVisitInput input, DataFetchingEnvironment environment, JwtUser jwtUser) {
    return visitRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(visit -> visitMapper.updateVisit(visit, input, environment))
        .map(this::saveVisit)
        .map(visitMapper::toGraphql);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Visit> softDeleteVisit(
      UUID visitId, JwtUser jwtUser) {
    log.info("Soft deleting visit: {}", visitId);
    return visitRepository
        .findByIdAndOwnerId(visitId, jwtUser.userId())
        .map(
            visit -> {
              visit.setDeletedAt(OffsetDateTime.now());
              return saveVisit(visit);
            })
        .map(visitMapper::toGraphql);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Visit> getVisitsByStudentId(
      UUID studentId, JwtUser jwtUser) {
    log.info("Getting visits by studentId={} for ownerId={}", studentId, jwtUser.userId());
    return visitRepository.findAllByStudentIdAndOwnerId(studentId, jwtUser.userId()).stream()
        .map(visitMapper::toGraphql)
        .toList();
  }

  private Visit saveVisit(Visit visit) {
    log.info("Saving visit: {}", visit);
    return visitRepository.saveAndFlush(visit);
  }

  @Transactional
  public void saveVisitList(List<Visit> visitList) {
    log.info("Saving visit list: {}", visitList);
    visitRepository.saveAllAndFlush(visitList);
  }
}
