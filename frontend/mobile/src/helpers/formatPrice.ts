export const formatPrice = (text: string) => {
  const cleaned = text.replaceAll(/[^0-9.]/g, '');

  const [integerPart, decimalPart] = cleaned.split('.');

  return decimalPart === undefined
    ? integerPart
    : `${integerPart}.${decimalPart.slice(0, 2)}`;
};
