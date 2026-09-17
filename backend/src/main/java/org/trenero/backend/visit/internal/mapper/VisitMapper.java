package org.trenero.backend.visit.internal.mapper;

import java.util.Map;
import java.util.UUID;
import lombok.NonNull;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.request.CreateVisitRequest;
import org.trenero.backend.common.response.VisitResponse;
import org.trenero.backend.visit.internal.domain.Visit;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface VisitMapper {

  VisitResponse toResponse(Visit visit);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Visit toVisit(CreateVisitRequest request, UUID ownerId);

  default @NonNull Visit updateVisit(@NonNull Visit visit, @NonNull Map<String, Object> updates) {
    if (updates.containsKey("status")) {
      VisitStatus status = VisitStatus.valueOf(updates.get("status").toString().toUpperCase());
      visit.setStatus(status);
    }

    return visit;
  }
}
