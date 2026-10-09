package org.trenero.backend.visit.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.internal.domain.Visit;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface VisitMapper {

  VisitResponse toResponse(Visit visit);
}
