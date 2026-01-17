package tech.trenero.backend.visit.internal.controller;

import graphql.schema.DataFetchingEnvironment;
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
import tech.trenero.backend.codegen.types.CreateVisitInput;
import tech.trenero.backend.codegen.types.UpdateVisitInput;
import tech.trenero.backend.codegen.types.Visit;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.visit.internal.service.VisitService;

@Controller
@RequiredArgsConstructor
@Validated
public class VisitController {
  private final VisitService visitService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<Visit> visits(@AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.getAllVisits(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Visit> visit(@Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.findVisitById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Visit createVisit(
      @Argument("input") @Valid CreateVisitInput input, @AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.createVisit(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Visit> updateVisit(
      @Argument("id") UUID id,
      @Argument("input") @Valid UpdateVisitInput input,
      DataFetchingEnvironment environment,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.updateVisit(id, input, environment, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Visit> deleteVisit(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return visitService.softDeleteVisit(id, jwtUser);
  }
}
