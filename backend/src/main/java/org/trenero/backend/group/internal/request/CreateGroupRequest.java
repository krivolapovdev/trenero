package org.trenero.backend.group.internal.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record CreateGroupRequest(
    @NotBlank @Size(max = 255) String name,
    BigDecimal defaultPrice,
    @Size(max = 255) String note,
    List<UUID> studentIds) {

  public CreateGroupRequest {
    studentIds = studentIds == null ? List.of() : studentIds;
  }
}
