package tech.trenero.backend.visit.internal.mapper;

import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.common.domain.VisitStatus;
import tech.trenero.backend.common.request.CreateVisitRequest;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.visit.internal.domain.Visit;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface VisitMapper {
  VisitResponse toResponse(Visit visit);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Visit toVisit(CreateVisitRequest request, UUID ownerId);

  default Visit updateVisit(Visit visit, Map<String, Object> updates) {
    if (visit == null || updates == null) {
      return visit;
    }

    if (updates.containsKey("status")) {
      VisitStatus status = VisitStatus.valueOf(updates.get("status").toString());
      visit.setStatus(status);
    }

    return visit;
  }
}
