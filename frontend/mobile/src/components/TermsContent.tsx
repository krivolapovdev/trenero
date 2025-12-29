import { Text } from 'react-native-paper';

export const TermsContent = () => (
  <>
    <Text
      variant='titleLarge'
      style={{ marginBottom: 12 }}
    >
      Terms & Privacy Policy
    </Text>

    <Text
      variant='bodyMedium'
      style={{ textAlign: 'justify', marginBottom: 12 }}
    >
      Terms of Service
      {'\n\n'}
      By accessing or using this application, you acknowledge that you have
      read, understood, and agree to be bound by these Terms of Service. The
      application is provided on an “as is” and “as available” basis, without
      warranties of any kind, whether express, implied, or statutory, including
      but not limited to implied warranties of merchantability, fitness for a
      particular purpose, and non-infringement.
    </Text>

    <Text
      variant='bodyMedium'
      style={{ textAlign: 'justify', marginBottom: 24 }}
    >
      Privacy Policy
      {'\n\n'}
      We collect and process only the information necessary to provide and
      maintain the application. Personal data is not sold, rented, or otherwise
      disclosed to third parties except as required by law. Reasonable
      administrative, technical, and organizational measures are implemented to
      protect personal data from unauthorized access, use, or disclosure.
    </Text>
  </>
);
