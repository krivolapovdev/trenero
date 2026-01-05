import { LinearGradient } from 'expo-linear-gradient';
import { View } from 'react-native';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = {
  value: number;
  isSelected: boolean;
};

export const BarItem = ({ value, isSelected }: Readonly<Props>) => {
  const theme = useAppTheme();

  const gradientColors = isSelected
    ? ([theme.colors.primary, theme.colors.primaryContainer] as const)
    : ([theme.colors.surfaceVariant, theme.colors.secondaryContainer] as const);

  return (
    <View style={{ flex: 1, width: 35, justifyContent: 'flex-end' }}>
      <LinearGradient
        colors={gradientColors}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={{
          width: '100%',
          height: `${value}%`,
          borderTopLeftRadius: 99,
          borderTopRightRadius: 99
        }}
      />
    </View>
  );
};
