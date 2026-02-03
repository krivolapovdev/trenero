import type { ConfigContext, ExpoConfig } from '@expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'Trenero',
  slug: 'trenero',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './src/assets/images/icon.png',
  scheme: 'mobile',
  userInterfaceStyle: 'automatic',
  newArchEnabled: true,
  ios: {
    supportsTablet: false,
    bundleIdentifier: 'org.trenero'
  },
  android: {
    adaptiveIcon: {
      backgroundColor: '#E6F4FE',
      foregroundImage: './src/assets/images/icon.png',
      monochromeImage: './src/assets/images/icon-monochrome.png'
    },
    predictiveBackGestureEnabled: false,
    package: 'org.trenero'
  },
  plugins: [
    'expo-router',
    [
      'expo-splash-screen',
      {
        image: './src/assets/images/icon.png',
        imageWidth: 200,
        resizeMode: 'contain',
        backgroundColor: '#ffffff',
        dark: {
          backgroundColor: '#000000'
        }
      }
    ],
    [
      '@react-native-google-signin/google-signin',
      {
        iosUrlScheme: process.env.EXPO_PUBLIC_GOOGLE_IOS_URL_SCHEME
      }
    ]
  ],
  experiments: {
    typedRoutes: true,
    reactCompiler: true
  },
  extra: {
    router: {},
    eas: {
      projectId: '782d57c4-ecfe-4ae6-98ab-4466ddc3da68'
    }
  },
  owner: 'krivolapovdevs-organization'
});
