package org.trenero.backend.group.internal.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record CreateGroupRequest(
    @NotNull @NotBlank String name, BigDecimal defaultPrice, String note, List<UUID> studentIds) {
  public CreateGroupRequest {
    studentIds = studentIds == null ? List.of() : studentIds;
  }
}
