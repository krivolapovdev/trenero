package tech.trenero.backend.group.internal.controller;

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
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.input.CreateGroupInput;
import tech.trenero.backend.group.internal.service.GroupService;

@Controller
@RequiredArgsConstructor
public class GroupController {
  private final GroupService groupService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<Group> groups(@AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getAllGroups(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<Group> group(@Argument UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getGroupById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Group createGroup(
      @Argument CreateGroupInput input, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.createGroup(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Group deleteGroup(@Argument UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.softDeleteGroup(id, jwtUser);
  }
}
