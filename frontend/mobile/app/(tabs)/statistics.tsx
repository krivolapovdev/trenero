import { Appbar, Text } from 'react-native-paper';

export default function StatisticsScreen() {
  return (
    <>
      <Appbar.Header
        mode='center-aligned'
        elevated
      >
        <Appbar.Content title='Statistics' />
      </Appbar.Header>
      <Text>Statistics</Text>
    </>
  );
}
