package org.trenero.backend.visit.internal.controller

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
import org.trenero.backend.common.request.CreateVisitRequest
import org.trenero.backend.common.response.VisitResponse
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.visit.internal.service.VisitService

@RestController
@RequestMapping("/api/v1/visits")
class VisitController(private val visitService: VisitService) {

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  fun getVisits(@AuthenticationPrincipal jwtUser: JwtUser): List<VisitResponse> =
    visitService.getAllVisits(jwtUser)

  @GetMapping("/{visitId}")
  @PreAuthorize("isAuthenticated()")
  fun getVisit(
    @PathVariable visitId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): VisitResponse = visitService.getVisitById(visitId, jwtUser)

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  fun createVisit(
    @RequestBody @Valid request: CreateVisitRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): VisitResponse = visitService.createVisit(request, jwtUser)

  @PatchMapping("/{visitId}")
  @PreAuthorize("isAuthenticated()")
  fun updateVisit(
    @PathVariable visitId: UUID,
    @RequestBody @Valid updates: Map<String, Any?>,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): VisitResponse = visitService.updateVisit(visitId, updates, jwtUser)

  @DeleteMapping("/{visitId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  fun deleteVisit(
    @PathVariable visitId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ) = visitService.deleteVisit(visitId, jwtUser)
}
