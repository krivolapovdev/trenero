import { type Href, Link } from 'expo-router';
import { memo } from 'react';
import { StyleSheet, type ViewStyle } from 'react-native';
import { Card, Divider, Text } from 'react-native-paper';
import { StatusBadges } from '@/src/components/StatusBadges';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type StatusBadge = {
  id: string;
  label: string;
  backgroundColor: string;
  textColor: string;
};

type Props = {
  title: string;
  subtitle?: string | null;
  href: Href;
  badges?: StatusBadge[];
  style?: ViewStyle;
};

export const EntityCard = memo(
  ({ title, subtitle, href, badges, style }: Props) => {
    const theme = useAppTheme();

    return (
      <Card
        mode='contained'
        style={[{ backgroundColor: theme.colors.surface }, style]}
      >
        <Link href={href}>
          <Card.Content style={styles.cardContent}>
            <Text variant='titleMedium'>{title}</Text>

            <Text
              variant='bodyMedium'
              style={styles.subtitle}
            >
              {subtitle}
            </Text>

            {badges && badges.length > 0 && (
              <>
                <Divider style={{ marginBottom: 10 }} />
                <StatusBadges badges={badges} />
              </>
            )}
          </Card.Content>
        </Link>
      </Card>
    );
  }
);

const styles = StyleSheet.create({
  cardContent: {
    borderRadius: 8,
    padding: 16,
    width: '100%'
  },
  subtitle: {
    paddingVertical: 10
  }
});
