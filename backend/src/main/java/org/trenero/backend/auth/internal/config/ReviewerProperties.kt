package org.trenero.backend.auth.internal.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.reviewer") data class ReviewerProperties(val key: String)
