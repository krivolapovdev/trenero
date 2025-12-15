import { StyleSheet, useColorScheme } from 'react-native';
import { Button, useTheme } from 'react-native-paper';

type Props = {
  label: string;
  icon: string;
  loading: boolean;
  disabled: boolean;
  onPress: () => Promise<void> | void;
};

export function SocialAuthButton({
  label,
  icon,
  loading,
  disabled,
  onPress
}: Readonly<Props>) {
  const theme = useTheme();
  const isDark = useColorScheme() === 'dark';

  return (
    <Button
      mode='elevated'
      focusable={false}
      icon={icon}
      loading={loading}
      disabled={disabled}
      contentStyle={styles.buttonContent}
      buttonColor={isDark ? theme.colors.surface : undefined}
      textColor={isDark ? theme.colors.onSurface : undefined}
      onPress={onPress}
    >
      {label}
    </Button>
  );
}

const styles = StyleSheet.create({
  buttonContent: {
    height: 52
  }
});
