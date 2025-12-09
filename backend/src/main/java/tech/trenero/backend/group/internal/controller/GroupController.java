package tech.trenero.backend.group.internal.controller;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.request.GroupRequest;
import tech.trenero.backend.group.internal.response.GroupWithStudentsResponse;
import tech.trenero.backend.group.internal.service.GroupService;

@RestController
@RequestMapping("/api/v1/groups")
@RequiredArgsConstructor
@Validated
public class GroupController {
  private final GroupService groupService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<GroupResponse> getAllGroupsForUser(@AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getAllGroupsForUser(jwtUser);
  }

  @GetMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public GroupWithStudentsResponse getGroupForUserById(
      @PathVariable UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getGroupForUserById(id, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  public UUID createGroupForUser(
      @RequestBody GroupRequest groupRequest, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.createGroupForUser(groupRequest, jwtUser);
  }
}
