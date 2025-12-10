package tech.trenero.backend.attendance.internal.client;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;

@Component
@RequiredArgsConstructor
public class AttendanceGroupClient {
  @Lazy private final GroupSpi groupSpi;

  public void getForUserById(UUID groupId, JwtUser jwtUser) {
    groupSpi.getForUserById(groupId, jwtUser);
  }
}
