package tech.trenero.backend.attendance.internal.client;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;

@Component
@RequiredArgsConstructor
@Slf4j
public class AttendanceGroupClient {
  @Lazy private final GroupSpi groupSpi;

  public void checkUserOwnsGroup(UUID groupId, JwtUser jwtUser) {
    log.debug("Checking if user owns group by id={} for user={}", groupId, jwtUser.userId());
    groupSpi.getGroupById(groupId, jwtUser);
  }
}
