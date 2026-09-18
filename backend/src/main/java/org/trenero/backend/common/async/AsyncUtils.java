package org.trenero.backend.common.async;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionException;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public final class AsyncUtils {

  public static void awaitAll(CompletableFuture<?>... futures) {
    try {
      CompletableFuture.allOf(futures).join();
    } catch (CompletionException e) {
      Throwable cause = e.getCause();
      if (cause instanceof RuntimeException runtimeEx) {
        throw runtimeEx;
      }
      throw new RuntimeException("Unexpected error during parallel execution", cause);
    }
  }
}
