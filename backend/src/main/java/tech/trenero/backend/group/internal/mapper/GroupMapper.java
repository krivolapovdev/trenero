package tech.trenero.backend.group.internal.mapper;

import graphql.schema.DataFetchingEnvironment;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.codegen.types.CreateGroupInput;
import tech.trenero.backend.codegen.types.UpdateGroupInput;
import tech.trenero.backend.group.internal.entity.Group;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface GroupMapper {
  tech.trenero.backend.codegen.types.Group toGraphql(Group group);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Group toGroup(CreateGroupInput input, UUID ownerId);

  default Group updateGroup(
      Group group, UpdateGroupInput input, DataFetchingEnvironment environment) {
    if (group == null || input == null || environment == null) {
      return group;
    }

    Map<String, Object> inputMap = environment.getArgument("input");
    if (inputMap == null) {
      return group;
    }

    Map<String, Runnable> updates =
        Map.of(
            "name", () -> group.setName(input.getName()),
            "defaultPrice", () -> group.setDefaultPrice(input.getDefaultPrice()),
            "note", () -> group.setNote(input.getNote()));

    updates.entrySet().stream()
        .filter(entry -> inputMap.containsKey(entry.getKey()))
        .forEach(entry -> entry.getValue().run());

    return group;
  }
}
