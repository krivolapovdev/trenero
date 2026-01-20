package tech.trenero.backend.group.internal.request;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public record UpdateGroupRequest(
    Optional<String> name,
    Optional<BigDecimal> defaultPrice,
    Optional<String> note,
    Optional<List<UUID>> studentIds) {}
