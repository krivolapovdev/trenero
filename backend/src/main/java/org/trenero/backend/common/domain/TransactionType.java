package org.trenero.backend.common.domain;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(name = "TransactionType", enumAsRef = true)
public enum TransactionType {
  INCOME,
  EXPENSE
}
