import dayjs from 'dayjs';

export const parsePastOrTodayDateFromInput = (
  value: string
): dayjs.Dayjs | null => {
  const parsed = dayjs(value, 'DD/MM/YYYY', true);

  if (!parsed.isValid() || parsed.isAfter(dayjs(), 'day')) {
    return null;
  }

  return parsed;
};
