import { View } from 'react-native';
import { Text } from 'react-native-paper';

type BadgeItem = {
  id: string | number;
  backgroundColor: string;
  textColor: string;
  label: string;
};

type Props = {
  badges: BadgeItem[];
};

export const StatusBadges = ({ badges }: Props) => {
  if (!badges?.length) {
    return null;
  }

  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: 8
      }}
    >
      {badges.map(badge => (
        <View
          key={badge.id}
          style={[
            {
              paddingHorizontal: 12,
              paddingVertical: 4,
              borderRadius: 16
            },
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
  );
};
