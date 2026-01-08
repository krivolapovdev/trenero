import { memo, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { ScrollView, useWindowDimensions } from 'react-native';
import { Button, Dialog, Portal } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = {
  visible: boolean;
  title: string;
  children: ReactNode;

  onConfirm: () => void;
  onCancel?: () => void;
  onDismiss?: () => void;

  confirmText?: string;
  cancelText?: string;

  disabledConfirm?: boolean;
  loading?: boolean;
};

export const ConfirmDialog = memo(
  ({
    visible,
    title,
    children,

    onConfirm,
    onCancel,
    onDismiss,

    confirmText,
    cancelText,

    disabledConfirm,
    loading
  }: Readonly<Props>) => {
    const { t } = useTranslation();
    const theme = useAppTheme();
    const { height } = useWindowDimensions();

    return (
      <Portal>
        <Dialog
          visible={visible}
          onDismiss={loading ? undefined : (onDismiss ?? onCancel)}
          style={{ maxHeight: 0.7 * height }}
        >
          <Dialog.Title>{title}</Dialog.Title>

          <Dialog.ScrollArea>
            <ScrollView
              contentContainerStyle={{ paddingVertical: 16 }}
              showsVerticalScrollIndicator={false}
            >
              {children}
            </ScrollView>
          </Dialog.ScrollArea>

          <Dialog.Actions>
            {onCancel && (
              <Button
                onPress={onCancel}
                disabled={loading}
                textColor={theme.colors.error}
              >
                {cancelText ?? t('cancel')}
              </Button>
            )}

            <Button
              onPress={onConfirm}
              disabled={disabledConfirm || loading}
              loading={loading}
            >
              {confirmText ?? t('ok')}
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    );
  }
);
