package org.trenero.backend.group.internal.controller

import jakarta.validation.Valid
import java.time.LocalDate
import java.util.UUID
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.format.annotation.DateTimeFormat.ISO
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
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.external.response.GroupResponse
import org.trenero.backend.group.internal.request.CreateGroupRequest
import org.trenero.backend.group.internal.response.GroupReportResponse
import org.trenero.backend.group.internal.response.GroupStudentSummaryResponse
import org.trenero.backend.group.internal.response.GroupSummaryResponse
import org.trenero.backend.group.internal.service.GroupService
import org.trenero.backend.lesson.external.response.LessonResponse

@RestController
@RequestMapping("/api/v1/groups")
class GroupController(private val groupService: GroupService) {

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  fun getAllGroupsSummary(@AuthenticationPrincipal jwtUser: JwtUser): List<GroupSummaryResponse> =
    groupService.getAllGroupsSummary(jwtUser)

  @GetMapping("/{groupId}/students")
  @PreAuthorize("isAuthenticated()")
  fun getGroupStudents(
    @PathVariable groupId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): List<GroupStudentSummaryResponse> = groupService.getGroupStudents(groupId, jwtUser)

  @GetMapping("/{groupId}/lessons")
  @PreAuthorize("isAuthenticated()")
  fun getGroupLessons(
    @PathVariable groupId: UUID,
    @RequestParam @DateTimeFormat(iso = ISO.DATE_TIME) from: LocalDate,
    @RequestParam @DateTimeFormat(iso = ISO.DATE_TIME) to: LocalDate,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): List<LessonResponse> = groupService.getGroupLessons(groupId, from, to, jwtUser)

  @GetMapping("/{groupId}/report")
  @PreAuthorize("isAuthenticated()")
  fun getGroupReport(
    @PathVariable groupId: UUID,
    @RequestParam year: Int,
    @RequestParam month: Int,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): GroupReportResponse = groupService.getGroupReport(groupId, year, month, jwtUser)

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  fun createGroup(
    @RequestBody @Valid request: CreateGroupRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): GroupResponse = groupService.createGroup(request, jwtUser)

  @PatchMapping("/{groupId}")
  @PreAuthorize("isAuthenticated()")
  fun updateGroup(
    @PathVariable groupId: UUID,
    @RequestBody updates: Map<String, Any?>,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): GroupResponse = groupService.updateGroup(groupId, updates, jwtUser)

  @DeleteMapping("/{groupId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  fun deleteGroup(
    @PathVariable groupId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ) {
    groupService.deleteGroup(groupId, jwtUser)
  }
}
