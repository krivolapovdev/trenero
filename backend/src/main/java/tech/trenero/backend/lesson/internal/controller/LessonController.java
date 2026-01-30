package tech.trenero.backend.lesson.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.internal.request.CreateLessonRequest;
import tech.trenero.backend.lesson.internal.request.UpdateLessonRequest;
import tech.trenero.backend.lesson.internal.response.LessonDetailsResponse;
import tech.trenero.backend.lesson.internal.service.LessonService;

@RestController
@RequestMapping("/api/v1/lessons")
@RequiredArgsConstructor
@Validated
public class LessonController {
  private final LessonService lessonService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<LessonResponse> getLessons(@AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.getAllLessons(jwtUser);
  }

  @GetMapping("/{lessonId}")
  @PreAuthorize("isAuthenticated()")
  public LessonResponse getLesson(
      @PathVariable("lessonId") UUID lessonId, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.getLessonById(lessonId, jwtUser);
  }

  @GetMapping("/{lessonId}/details")
  @PreAuthorize("isAuthenticated()")
  public LessonDetailsResponse getLessonDetails(
      @PathVariable UUID lessonId, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.getLessonDetailsById(lessonId, jwtUser);
  }

  @GetMapping("/{lessonId}/visits")
  @PreAuthorize("isAuthenticated()")
  public List<VisitResponse> getLessonVisits(
      @PathVariable("lessonId") UUID lessonId, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.getVisitsByLessonId(lessonId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public LessonResponse createLesson(
      @RequestBody @Valid CreateLessonRequest request, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.createLesson(request, jwtUser);
  }

  @PatchMapping("/{lessonId}")
  @PreAuthorize("isAuthenticated()")
  public LessonResponse updateLesson(
      @PathVariable("lessonId") UUID lessonId,
      @RequestBody @Valid UpdateLessonRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.updateLesson(lessonId, request, jwtUser);
  }

  @DeleteMapping("/{lessonId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteLesson(
      @PathVariable("lessonId") UUID lessonId, @AuthenticationPrincipal JwtUser jwtUser) {
    lessonService.deleteLesson(lessonId, jwtUser);
  }
}
