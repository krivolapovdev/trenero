package tech.trenero.backend.visit.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
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
import tech.trenero.backend.common.request.CreateVisitRequest;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.visit.internal.service.VisitService;

@RestController
@RequestMapping("/api/v1/visits")
@RequiredArgsConstructor
@Validated
public class VisitController {
  private final VisitService visitService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<VisitResponse> getVisits(@AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.getAllVisits(jwtUser);
  }

  @GetMapping("/{visitId}")
  @PreAuthorize("isAuthenticated()")
  public VisitResponse getVisit(
      @PathVariable("visitId") UUID visitId, @AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.getVisitById(visitId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public VisitResponse createVisit(
      @RequestBody @Valid CreateVisitRequest request, @AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.createVisit(request, jwtUser);
  }

  @PatchMapping("/{visitId}")
  @PreAuthorize("isAuthenticated()")
  public VisitResponse updateVisit(
      @PathVariable("visitId") UUID visitId,
      @RequestBody @Valid Map<String, Object> updates,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.updateVisit(visitId, updates, jwtUser);
  }

  @DeleteMapping("/{visitId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteVisit(
      @PathVariable("visitId") UUID visitId, @AuthenticationPrincipal JwtUser jwtUser) {
    visitService.softDeleteVisit(visitId, jwtUser);
  }
}
