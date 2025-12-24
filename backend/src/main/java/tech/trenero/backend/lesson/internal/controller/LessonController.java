package tech.trenero.backend.lesson.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.internal.entity.Lesson;
import tech.trenero.backend.lesson.internal.input.CreateLessonInput;
import tech.trenero.backend.lesson.internal.service.LessonService;

@Controller
@RequiredArgsConstructor
@Validated
public class LessonController {
  private final LessonService lessonService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<Lesson> lessons(@AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.getAllLessons(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Lesson> lesson(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.getLessonById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Lesson createLesson(
      @Argument("input") @Valid CreateLessonInput input, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.createLesson(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Lesson> deleteLesson(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonService.softDeleteLesson(id, jwtUser);
  }
}
