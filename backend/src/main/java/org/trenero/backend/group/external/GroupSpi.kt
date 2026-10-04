package org.trenero.backend.group.external

import java.util.UUID
import org.trenero.backend.common.response.GroupResponse
import org.trenero.backend.common.security.JwtUser

interface GroupSpi {

  fun getGroupById(groupId: UUID, jwtUser: JwtUser): GroupResponse

  fun getGroupsByIds(groupIds: List<UUID>, jwtUser: JwtUser): Map<UUID, GroupResponse>
}
