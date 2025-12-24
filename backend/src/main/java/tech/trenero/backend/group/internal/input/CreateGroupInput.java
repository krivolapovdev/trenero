package tech.trenero.backend.group.internal.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record CreateGroupInput(
    @NotNull @NotBlank @Size(max = 255) String name, BigDecimal defaultPrice) {}
