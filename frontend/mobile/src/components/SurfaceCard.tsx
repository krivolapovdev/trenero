import { memo, type ReactNode } from 'react';
import { View, type ViewProps } from 'react-native';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = ViewProps & {
  children: ReactNode;
};

export const SurfaceCard = memo(
  ({ style, children, ...rest }: Readonly<Props>) => {
    const theme = useAppTheme();

    return (
      <View
        style={[
          {
            borderRadius: 16,
            padding: 16,
            backgroundColor: theme.colors.surface
          },
          style
        ]}
        {...rest}
      >
        {children}
      </View>
    );
  }
);
