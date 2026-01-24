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
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.StudentResponse;
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

  @GetMapping("/{groupId}")
  @PreAuthorize("isAuthenticated()")
  public GroupResponse getGroup(
      @PathVariable("groupId") UUID groupId, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getGroupById(groupId, jwtUser);
  }

  @GetMapping("/{groupId}/students")
  @PreAuthorize("isAuthenticated()")
  public List<StudentResponse> getGroupStudents(
      @PathVariable("groupId") UUID groupId, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getStudentsByGroupId(groupId, jwtUser);
  }

  @GetMapping("/{groupId}/lessons")
  @PreAuthorize("isAuthenticated()")
  public List<LessonResponse> getGroupLessons(
      @PathVariable("groupId") UUID groupId, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.getLessonsByGroupId(groupId, jwtUser);
  }

  @PostMapping
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.CREATED)
  public GroupResponse createGroup(
      @RequestBody @Valid CreateGroupRequest request, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.createGroup(request, jwtUser);
  }

  @PatchMapping("/{groupId}")
  @PreAuthorize("isAuthenticated()")
  public GroupResponse updateGroup(
      @PathVariable("groupId") UUID groupId,
      @RequestBody @Valid UpdateGroupRequest request,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return groupService.updateGroup(groupId, request, jwtUser);
  }

  @DeleteMapping("/{groupId}")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteGroup(
      @PathVariable("groupId") UUID groupId, @AuthenticationPrincipal JwtUser jwtUser) {
    groupService.softDeleteGroup(groupId, jwtUser);
  }
}
