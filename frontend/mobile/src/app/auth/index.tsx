import { Image } from 'expo-image';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  Alert,
  Linking,
  Pressable,
  StyleSheet,
  useWindowDimensions,
  View
} from 'react-native';
import { Divider, Text, TextInput } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ConfirmDialog } from '@/src/components/Dialog/ConfirmDialog';
import { SocialButtonsGroup } from '@/src/components/SocialButtonsGroup';
import { PRIVACY_POLICY_URL } from '@/src/data/constants';
import { extractErrorMessage } from '@/src/helpers/apiError'; // путь к вашему компоненту
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useReviewerSignIn } from '@/src/hooks/useReviewerSignIn';

export default function LoginScreen() {
  const theme = useAppTheme();
  const { t } = useTranslation();
  const { width, height } = useWindowDimensions();

  const [isDialogVisible, setIsDialogVisible] = useState(false);
  const [reviewerKey, setReviewerKey] = useState('');

  const { signIn, isLoading } = useReviewerSignIn();

  const handleCancel = () => {
    setIsDialogVisible(false);
    setReviewerKey('');
  };

  const handleConfirm = async () => {
    try {
      await signIn(reviewerKey);
      setIsDialogVisible(false);
    } catch (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
    }
  };

  return (
    <SafeAreaView
      style={[
        styles.safeArea,
        { backgroundColor: theme.colors.surfaceVariant }
      ]}
    >
      <ConfirmDialog
        visible={isDialogVisible}
        title='Reviewer Access'
        confirmText='Login'
        onConfirm={handleConfirm}
        onCancel={handleCancel}
        loading={isLoading}
        disabledConfirm={!reviewerKey.trim()}
      >
        <TextInput
          label='Reviewer Key'
          value={reviewerKey}
          onChangeText={setReviewerKey}
          mode='outlined'
          secureTextEntry={true}
          autoFocus={true}
        />
      </ConfirmDialog>

      <View style={styles.container}>
        <View style={styles.content}>
          <Pressable onLongPress={() => setIsDialogVisible(true)}>
            <View style={styles.logoContainer}>
              <Image
                style={{ width, height: height * 0.3 }}
                source={require('@/src/assets/images/tiny-people-carrying-key-to-open-padlock.svg')}
                contentFit='contain'
              />
            </View>
          </Pressable>

          <SocialButtonsGroup />
        </View>

        <View style={styles.bottomContainer}>
          <Divider
            style={[styles.divider, { backgroundColor: theme.colors.outline }]}
          />

          <Text
            variant='bodySmall'
            onPress={() => Linking.openURL(PRIVACY_POLICY_URL)}
            style={{
              color: theme.colors.onSurfaceVariant,
              textAlign: 'center'
            }}
          >
            {t('agreeText')}
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },
  container: { flex: 1, padding: 24 },
  content: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  logoContainer: { alignItems: 'center' },
  bottomContainer: { paddingBottom: 8 },
  divider: { width: '100%', marginBottom: 12 }
});
