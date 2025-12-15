import { Appbar, Text } from 'react-native-paper';

export default function StudentsScreen() {
  return (
    <>
      <Appbar.Header
        mode='center-aligned'
        elevated
      >
        <Appbar.Content title='Students' />
      </Appbar.Header>
      <Text>Students</Text>
    </>
  );
}
