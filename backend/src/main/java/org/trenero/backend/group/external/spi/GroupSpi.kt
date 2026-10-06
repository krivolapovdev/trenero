package org.trenero.backend.group.external.spi

import java.util.UUID
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.external.response.GroupResponse

interface GroupSpi {

  fun getGroupById(groupId: UUID, jwtUser: JwtUser): GroupResponse

  fun getGroupsByIds(groupIds: List<UUID>, jwtUser: JwtUser): Map<UUID, GroupResponse>
}
