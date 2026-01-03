export const formatDate = (value: string) => {
  const digits = value.replaceAll(/\D/g, '').slice(0, 8);

  const day = digits.slice(0, 2);
  const month = digits.slice(2, 4);
  const year = digits.slice(4, 8);

  return [day, month, year].filter(Boolean).join('/');
};
