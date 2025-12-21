package tech.trenero.backend.group.internal.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record CreateGroupRequest(@NotBlank @Size(max = 255) String name, BigDecimal defaultPrice) {}
