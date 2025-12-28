import { ApolloLink, Observable } from '@apollo/client';

const DEFAULT_TIMEOUT = 10000;

export const timeoutLink = new ApolloLink((operation, forward) => {
  const timeout = operation.getContext().timeout || DEFAULT_TIMEOUT;

  return new Observable(observer => {
    const controller = new AbortController();

    const timer = setTimeout(() => {
      controller.abort();
      observer.error(new Error(`Timeout: Request exceeded ${timeout}ms`));
    }, timeout);

    operation.setContext(({ fetchOptions = {} }) => ({
      fetchOptions: {
        ...fetchOptions,
        signal: controller.signal
      }
    }));

    const subscription = forward(operation).subscribe({
      next: data => {
        clearTimeout(timer);
        observer.next(data);
      },
      error: err => {
        clearTimeout(timer);
        observer.error(err);
      },
      complete: () => {
        clearTimeout(timer);
        observer.complete();
      }
    });

    return () => {
      clearTimeout(timer);
      subscription.unsubscribe();
    };
  });
});
