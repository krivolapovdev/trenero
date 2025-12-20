import { Link } from 'expo-router';
import { ScrollView } from 'react-native';
import { Button, Text } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';
import { useAppTheme } from '@/hooks/useAppTheme';

export default function StatisticsScreen() {
  const theme = useAppTheme();

  return (
    <>
      <CustomAppbar title={'Statistics'} />

      <ScrollView
        contentContainerStyle={{ padding: 16 }}
        showsVerticalScrollIndicator={false}
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant
        }}
      >
        <Text>Statistics</Text>
        <Link href={'/(tabs)/groups'}>
          <Button>
            <Text>CLICK</Text>
          </Button>
        </Link>
      </ScrollView>
    </>
  );
}
