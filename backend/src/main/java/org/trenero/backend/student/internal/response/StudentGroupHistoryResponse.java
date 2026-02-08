package org.trenero.backend.student.internal.response;

import jakarta.validation.constraints.NotNull;
import java.util.List;
import org.trenero.backend.common.response.GroupResponse;

public record StudentGroupHistoryResponse(
    @NotNull GroupResponse group,
    @NotNull List<VisitWithLessonResponse> visits,
    @NotNull Boolean isCurrent) {}
