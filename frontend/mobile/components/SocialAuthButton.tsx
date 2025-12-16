import { StyleSheet } from 'react-native';
import { Button } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';

type Props = {
  label: string;
  icon: string;
  loading: boolean;
  disabled: boolean;
  onPress: () => Promise<void> | void;
};

export const SocialAuthButton = ({
  label,
  icon,
  loading,
  disabled,
  onPress
}: Readonly<Props>) => {
  const theme = useAppTheme();

  return (
    <Button
      mode='text'
      focusable={false}
      icon={icon}
      loading={loading}
      disabled={disabled}
      contentStyle={styles.buttonContent}
      buttonColor={theme.colors.surface}
      textColor={theme.colors.onSurface}
      onPress={onPress}
    >
      {label}
    </Button>
  );
};

const styles = StyleSheet.create({
  buttonContent: {
    height: 52
  }
});
