import { memo, useState } from 'react';
import {
  Text,
  TextInput,
  type TextInputProps,
  useTheme
} from 'react-native-paper';

export const CustomTextInput = memo(
  ({ label, value, onChangeText, ...rest }: TextInputProps) => {
    const theme = useTheme();
    const [isFocused, setIsFocused] = useState(false);

    return (
      <TextInput
        mode='outlined'
        theme={{
          roundness: 10
        }}
        value={value}
        label={
          <Text
            style={{
              color:
                (value && value.length > 0) || isFocused
                  ? theme.colors.primary
                  : theme.colors.secondary
            }}
          >
            {label}
          </Text>
        }
        outlineStyle={{ borderWidth: 0 }}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        onChangeText={onChangeText}
        {...rest}
      />
    );
  }
);
