package tech.trenero.backend.common.response;

import java.math.BigDecimal;
import java.util.UUID;

public record GroupResponse(UUID id, String name, BigDecimal defaultPrice) {}
