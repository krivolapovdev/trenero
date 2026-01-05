package tech.trenero.backend.group.internal.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record CreateGroupInput(
    @NotNull @NotBlank @Size(max = 255) String name,
    BigDecimal defaultPrice,
    @Size(max = 1023) String note,
    List<UUID> studentIds) {
  public CreateGroupInput {
    studentIds = studentIds == null ? List.of() : studentIds;
  }
}
