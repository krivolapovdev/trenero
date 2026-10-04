package org.trenero.backend.lesson.internal.controller

import jakarta.validation.Valid
import java.util.UUID
import org.springframework.http.HttpStatus
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.common.response.LessonResponse
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.lesson.internal.request.CreateLessonRequest
import org.trenero.backend.lesson.internal.request.UpdateLessonRequest
import org.trenero.backend.lesson.internal.response.LessonDetailsResponse
import org.trenero.backend.lesson.internal.service.LessonService

@RestController
@RequestMapping("/api/v1/lessons")
class LessonController(private val lessonService: LessonService) {

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  fun getLessons(@AuthenticationPrincipal jwtUser: JwtUser): List<LessonResponse> =
    lessonService.getAllLessons(jwtUser)

  @GetMapping("/{lessonId}")
  @PreAuthorize("isAuthenticated()")
  fun getLesson(
    @PathVariable lessonId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): LessonResponse = lessonService.getLessonById(lessonId, jwtUser)

  @GetMapping("/{lessonId}/details")
  @PreAuthorize("isAuthenticated()")
  fun getLessonDetails(
    @PathVariable lessonId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): LessonDetailsResponse = lessonService.getLessonDetailsById(lessonId, jwtUser)

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  fun createLesson(
    @RequestBody @Valid request: CreateLessonRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): LessonResponse = lessonService.createLesson(request, jwtUser)

  @PatchMapping("/{lessonId}")
  @PreAuthorize("isAuthenticated()")
  fun updateLesson(
    @PathVariable lessonId: UUID,
    @RequestBody @Valid request: UpdateLessonRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): LessonResponse = lessonService.updateLesson(lessonId, request, jwtUser)

  @DeleteMapping("/{lessonId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  fun deleteLesson(
    @PathVariable lessonId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ) {
    lessonService.deleteLesson(lessonId, jwtUser)
  }
}
