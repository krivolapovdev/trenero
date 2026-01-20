package tech.trenero.backend.group.internal.controller;

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
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.request.CreateGroupRequest;
import tech.trenero.backend.group.internal.request.UpdateGroupRequest;
import tech.trenero.backend.group.internal.service.GroupService;

@RestController
@RequestMapping("/api/v1/groups")
@RequiredArgsConstructor
@Validated
public class GroupController {
  private final GroupService groupService;

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  public List<GroupResponse> getGroups(@AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getAllGroups(jwtUser);
  }

  @GetMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public GroupResponse getGroup(@PathVariable UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getGroupById(id, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public GroupResponse createGroup(
      @RequestBody @Valid CreateGroupRequest request, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.createGroup(request, jwtUser);
  }

  @PatchMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public GroupResponse updateGroup(
      @PathVariable UUID id,
      @RequestBody @Valid UpdateGroupRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.updateGroup(id, request, jwtUser);
  }

  @DeleteMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteGroup(@PathVariable UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    groupService.softDeleteGroup(id, jwtUser);
  }
}
