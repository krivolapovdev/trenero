package tech.trenero.backend.visit.internal.mapper;

import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.visit.internal.entity.Visit;
import tech.trenero.backend.visit.internal.request.CreateVisitRequest;
import tech.trenero.backend.visit.internal.request.UpdateVisitRequest;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface VisitMapper {
  VisitResponse toResponse(Visit visit);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Visit toVisit(CreateVisitRequest request, UUID ownerId);

  default Visit updateVisit(Visit visit, UpdateVisitRequest input) {
    if (visit == null || input == null) {
      return visit;
    }

    input.present().ifPresent(visit::setPresent);

    return visit;
  }
}
