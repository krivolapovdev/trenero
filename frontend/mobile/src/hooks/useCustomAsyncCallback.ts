import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import type { ApiError } from '@/src/types/error';

type ApiCall<TArgs, TRes> = (
  args: TArgs
) => Promise<{ data?: TRes; error?: ApiError }>;

export const useCustomAsyncCallback = <TArgs, TRes>(
  apiMethod: ApiCall<TArgs, TRes>
) => {
  const { t } = useTranslation();

  return useAsyncCallback(async (args: TArgs) => {
    const { data, error } = await apiMethod(args);

    if (error || !data) {
      throw error ?? new Error(t('unexpectedError'));
    }

    return data;
  });
};
