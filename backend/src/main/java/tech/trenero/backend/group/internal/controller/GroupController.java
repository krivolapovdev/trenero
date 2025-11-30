package tech.trenero.backend.group.internal.controller;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.response.GroupResponse;
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
  public List<GroupResponse> getAllGroups() {
    return groupService.getAllGroups();
  }

  @GetMapping("/{id}")
  public GroupWithStudentsResponse getGroupById(@PathVariable UUID id) {
    return groupService.getGroupById(id);
  }

  @PostMapping
  public UUID createGroup(@RequestBody GroupRequest groupRequest) {
    return groupService.createGroup(groupRequest);
  }
}
