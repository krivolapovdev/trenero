import { Link } from 'expo-router';
import { Button, Text } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { CustomAppBar } from '@/components/CustomAppBar';
import { useAppTheme } from '@/hooks/useAppTheme';

export default function StatisticsScreen() {
  const theme = useAppTheme();

  return (
    <>
      <CustomAppBar title={'Statistics'} />

      <SafeAreaView
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant,
          paddingHorizontal: 16
        }}
      >
        <Text>Statistics</Text>
        <Link href={'/(tabs)/groups'}>
          <Button>CLICK</Button>
        </Link>
      </SafeAreaView>
    </>
  );
}
