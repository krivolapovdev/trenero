package tech.trenero.backend.user.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.UserDto;
import tech.trenero.backend.user.internal.entity.OAuth2User;

@Mapper(componentModel = ComponentModel.SPRING)
public interface UserMapper {
  UserDto toUserResponse(OAuth2User user);
}
