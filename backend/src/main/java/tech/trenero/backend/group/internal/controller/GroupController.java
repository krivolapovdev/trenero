package tech.trenero.backend.group.internal.controller;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.request.AddStudentRequest;
import tech.trenero.backend.group.internal.request.CreateGroupRequest;
import tech.trenero.backend.group.internal.request.RemoveStudentRequest;
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
  public List<GroupResponse> getAllGroups(@AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getAllGroups(jwtUser);
  }

  @GetMapping("/{groupId}")
  @PreAuthorize("isAuthenticated()")
  public GroupWithStudentsResponse getGroupWithStudentsById(
      @PathVariable UUID groupId, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getGroupWithStudentsById(groupId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public UUID createGroup(
      @RequestBody CreateGroupRequest createGroupRequest,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.createGroup(createGroupRequest, jwtUser);
  }

  @PostMapping("/{groupId}/students")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public void addStudentToGroup(
      @PathVariable UUID groupId,
      @RequestBody AddStudentRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    groupService.addStudentToGroup(groupId, request, jwtUser);
  }

  @DeleteMapping("/{groupId}/students")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void removeStudentFromGroup(
      @PathVariable UUID groupId,
      @RequestBody RemoveStudentRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    groupService.removeStudentFromGroup(groupId, request, jwtUser);
  }
}
