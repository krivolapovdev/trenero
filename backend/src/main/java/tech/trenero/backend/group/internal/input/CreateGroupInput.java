package tech.trenero.backend.group.internal.input;

import java.math.BigDecimal;

public record CreateGroupInput(String name, BigDecimal defaultPrice) {}
