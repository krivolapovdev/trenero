import { type Href, Link } from 'expo-router';
import { memo } from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import { Card, Divider, Text } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';

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
                <Divider style={styles.divider} />

                <View style={styles.statusContainer}>
                  {badges.map(badge => (
                    <View
                      key={badge.id}
                      style={[
                        styles.badge,
                        { backgroundColor: badge.backgroundColor }
                      ]}
                    >
                      <Text
                        variant='bodyMedium'
                        style={{ color: badge.textColor }}
                      >
                        {badge.label}
                      </Text>
                    </View>
                  ))}
                </View>
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
  },
  divider: {
    height: 1
  },
  statusContainer: {
    paddingTop: 10,
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: 8
  },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 16
  }
});
