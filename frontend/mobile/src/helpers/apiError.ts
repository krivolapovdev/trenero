import axios from 'axios';

type ApiErrorResponse = {
  detail?: string;
  title?: string;
  status?: number;
  instance?: string;
};

export const extractErrorMessage = (e: unknown): string => {
  if (axios.isAxiosError(e)) {
    const serverError = e.response?.data as ApiErrorResponse | undefined;

    return serverError?.detail || serverError?.title || e.message;
  }

  if (e instanceof Error) {
    return e.message;
  }

  return 'Unknown error occurred';
};
