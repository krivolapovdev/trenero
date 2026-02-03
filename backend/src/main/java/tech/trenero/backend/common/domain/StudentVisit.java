package tech.trenero.backend.common.domain;

import java.util.UUID;
import lombok.NonNull;

public record StudentVisit(@NonNull UUID studentId, @NonNull VisitStatus status) {}
