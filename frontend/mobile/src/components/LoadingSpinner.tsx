import { ActivityIndicator, View } from 'react-native';

export const LoadingSpinner = () => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
    <ActivityIndicator
      animating={true}
      size='large'
      color='black'
    />
  </View>
);
