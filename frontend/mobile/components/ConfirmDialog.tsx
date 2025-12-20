import type { ReactNode } from 'react';
import { Text } from 'react-native';
import { Button, Dialog, Portal } from 'react-native-paper';

type Props = {
  visible: boolean;
  title?: string;
  children: ReactNode;
  onConfirm: () => void;
  onCancel?: () => void;
  confirmText?: string;
  cancelText?: string;
};

export function ConfirmDialog({
  visible,
  title,
  children,
  onConfirm,
  onCancel,
  confirmText = 'OK',
  cancelText = 'Cancel'
}: Readonly<Props>) {
  return (
    <Portal>
      <Dialog
        visible={visible}
        onDismiss={onCancel}
      >
        {title && <Dialog.Title>{title}</Dialog.Title>}
        <Dialog.Content>
          {typeof children === 'string' ? <Text>{children}</Text> : children}
        </Dialog.Content>
        <Dialog.Actions>
          {onCancel && <Button onPress={onCancel}>{cancelText}</Button>}
          <Button onPress={onConfirm}>{confirmText}</Button>
        </Dialog.Actions>
      </Dialog>
    </Portal>
  );
}
