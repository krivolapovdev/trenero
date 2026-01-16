package tech.trenero.backend.user.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.codegen.types.User;
import tech.trenero.backend.user.internal.entity.OAuth2User;

@Mapper(componentModel = ComponentModel.SPRING)
public interface UserMapper {
  User toGraphql(OAuth2User user);
}
