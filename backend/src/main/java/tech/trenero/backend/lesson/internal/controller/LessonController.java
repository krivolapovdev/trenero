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
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.internal.request.CreateLessonRequest;
import tech.trenero.backend.lesson.internal.request.UpdateLessonRequest;
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

  @GetMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public LessonResponse getLesson(@PathVariable UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.getLessonById(id, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public LessonResponse createLesson(
      @RequestBody @Valid CreateLessonRequest request, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.createLesson(request, jwtUser);
  }

  @PatchMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public LessonResponse updateLesson(
      @PathVariable UUID id,
      @RequestBody @Valid UpdateLessonRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.updateLesson(id, request, jwtUser);
  }

  @DeleteMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteLesson(@PathVariable UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    lessonService.softDeleteLesson(id, jwtUser);
  }
}
