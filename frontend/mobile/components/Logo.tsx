import { Image, StyleSheet } from 'react-native';

export const Logo = () => {
  return (
    <Image
      style={styles.logo}
      source={require('../assets/images/icon.png')}
      resizeMode='contain'
    />
  );
};

const styles = StyleSheet.create({
  logo: {
    width: 160,
    height: 160,
    marginBottom: 100
  }
});
