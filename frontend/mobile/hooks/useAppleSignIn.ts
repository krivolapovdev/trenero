import { useState } from 'react';

export function useAppleSignIn(
  setErrorMessage: (message: string | null) => void
) {
  const [loading, setLoading] = useState(false);

  const signIn = async () => {
    if (loading) {
      return;
    }

    try {
      setLoading(true);
      setErrorMessage(null);
      await new Promise<void>(resolve => setTimeout(resolve, 3000));
    } finally {
      setLoading(false);
    }
  };

  return { signIn, loading };
}
