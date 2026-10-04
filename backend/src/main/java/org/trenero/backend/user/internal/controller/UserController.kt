package org.trenero.backend.user.internal.controller

import org.springframework.http.HttpStatus
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.internal.service.UserService

@RestController
@RequestMapping("/api/v1/users")
class UserController(private val userService: UserService) {

  @DeleteMapping("/me")
  @PreAuthorize("isAuthenticated()")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  fun deleteMyAccount(@AuthenticationPrincipal jwtUser: JwtUser) = userService.deleteUser(jwtUser)
}
