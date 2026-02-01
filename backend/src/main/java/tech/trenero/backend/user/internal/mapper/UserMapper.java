package tech.trenero.backend.user.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.response.UserResponse;
import tech.trenero.backend.user.internal.domain.OAuth2User;

@Mapper(componentModel = ComponentModel.SPRING)
public interface UserMapper {
  UserResponse toGraphql(OAuth2User user);
}
