import { memo } from 'react';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { formatDateInput } from '@/src/helpers/formatDateInput';

type DateInputProps = {
  label: string;
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
  required?: boolean;
};

export const DateInput = memo(
  ({ label, value, onChange, disabled, required }: DateInputProps) => (
    <CustomTextInput
      label={label}
      value={value}
      onChangeText={text => onChange(formatDateInput(text))}
      placeholder='31.12.1987'
      keyboardType='numeric'
      maxLength={10}
      disabled={disabled}
      required={required}
    />
  )
);
