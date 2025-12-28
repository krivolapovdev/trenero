import { Text } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = {
  error?: string | null;
};

export const OptionalErrorMessage = ({ error }: Props) => {
  const theme = useAppTheme();

  if (!error) {
    return null;
  }

  return (
    <Text
      variant='bodyLarge'
      style={{
        color: theme.colors.error,
        paddingVertical: 16,
        textAlign: 'center',
        width: '100%'
      }}
    >
      {error}
    </Text>
  );
};
