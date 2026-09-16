package org.trenero.backend.group.internal.request;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record CreateGroupRequest(
    @NotBlank String name, BigDecimal defaultPrice, String note, List<UUID> studentIds) {
  public CreateGroupRequest {
    studentIds = studentIds == null ? List.of() : studentIds;
  }
}
