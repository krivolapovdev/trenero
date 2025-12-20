import { Link } from 'expo-router';
import { Button, Text } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { CustomAppbar } from '@/components/CustomAppbar';
import { useAppTheme } from '@/hooks/useAppTheme';

export default function StatisticsScreen() {
  const theme = useAppTheme();

  return (
    <>
      <CustomAppbar title={'Statistics'} />

      <SafeAreaView
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant,
          paddingHorizontal: 16
        }}
      >
        <Text>Statistics</Text>
        <Link href={'/(tabs)/groups'}>
          <Button>
            <Text>CLICK</Text>
          </Button>
        </Link>
      </SafeAreaView>
    </>
  );
}
