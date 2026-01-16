package tech.trenero.backend.group.internal.controller;

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
import tech.trenero.backend.codegen.types.CreateGroupInput;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.codegen.types.UpdateGroupInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.service.GroupService;

@Controller
@RequiredArgsConstructor
@Validated
public class GroupController {
  private final GroupService groupService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<Group> groups(@AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getAllGroups(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Group> group(@Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.findGroupById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Group createGroup(
      @Argument("input") @Valid CreateGroupInput input, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.createGroup(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Group> updateGroup(
      @Argument("id") UUID id,
      @Argument("input") @Valid UpdateGroupInput input,
      DataFetchingEnvironment environment,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.updateGroup(id, input, environment, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Group> deleteGroup(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.softDeleteGroup(id, jwtUser);
  }
}
