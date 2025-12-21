import { memo, type ReactNode } from 'react';
import { Button, Dialog, Portal } from 'react-native-paper';

type Props = {
  visible: boolean;
  title?: string;
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
    confirmText = 'OK',
    cancelText = 'Cancel',
    disabledConfirm,
    loading
  }: Readonly<Props>) => {
    return (
      <Portal>
        <Dialog
          visible={visible}
          onDismiss={onDismiss ?? onCancel}
        >
          {title && <Dialog.Title>{title}</Dialog.Title>}
          <Dialog.Content>{children}</Dialog.Content>
          <Dialog.Actions>
            {onCancel && <Button onPress={onCancel}>{cancelText}</Button>}
            <Button
              onPress={onConfirm}
              disabled={disabledConfirm || loading}
              loading={loading}
            >
              {confirmText}
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    );
  }
);
