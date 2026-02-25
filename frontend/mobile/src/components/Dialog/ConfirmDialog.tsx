import { memo, type ReactNode, useEffect, useState } from 'react';
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
  delay?: number;
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

    disabledConfirm = false,
    loading = false,
    delay = 0
  }: Readonly<Props>) => {
    const { t } = useTranslation();
    const theme = useAppTheme();
    const { height } = useWindowDimensions();

    const [secondsLeft, setSecondsLeft] = useState(delay);

    useEffect(() => {
      if (visible && delay > 0) {
        setSecondsLeft(delay);

        const interval = setInterval(() => {
          setSecondsLeft(prev => {
            if (prev <= 1) {
              clearInterval(interval);
              return 0;
            }
            return prev - 1;
          });
        }, 1000);

        return () => clearInterval(interval);
      }

      if (!visible) {
        setSecondsLeft(0);
      }
    }, [visible, delay]);

    const isConfirmDisabled = disabledConfirm || loading || secondsLeft > 0;
    const okLabel = confirmText ?? t('ok');

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
              disabled={isConfirmDisabled}
              loading={loading}
            >
              {secondsLeft > 0 ? `${okLabel} (${secondsLeft}s)` : okLabel}
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    );
  }
);
