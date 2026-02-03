package org.trenero.backend.payment.external;

import java.util.List;
import org.trenero.backend.common.response.TransactionResponse;
import org.trenero.backend.common.security.JwtUser;

public interface TransactionSpi {
  List<TransactionResponse> getAllTransactions(JwtUser jwtUser);
}
