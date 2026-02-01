package tech.trenero.backend.payment.external;

import java.util.List;
import tech.trenero.backend.common.response.TransactionResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface TransactionSpi {
  List<TransactionResponse> getAllTransactions(JwtUser jwtUser);
}
