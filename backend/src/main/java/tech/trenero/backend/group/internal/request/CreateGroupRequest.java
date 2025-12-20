package tech.trenero.backend.group.internal.request;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

public record CreateGroupRequest(@NotBlank String name, BigDecimal defaultPrice) {}
