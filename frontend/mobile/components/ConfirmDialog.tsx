import type { ReactNode } from 'react';
import { Text, type ViewStyle } from 'react-native';
import { Button, Dialog, Portal } from 'react-native-paper';

type Props = {
  visible: boolean;
  title?: string;
  message: ReactNode;
  onConfirm: () => void;
  onCancel?: () => void;
  confirmText?: string;
  cancelText?: string;
  contentStyle?: ViewStyle;
};

export function ConfirmDialog({
  visible,
  title,
  message,
  onConfirm,
  onCancel,
  confirmText = 'OK',
  cancelText = 'Cancel',
  contentStyle
}: Readonly<Props>) {
  return (
    <Portal>
      <Dialog
        visible={visible}
        onDismiss={onCancel}
      >
        {title && <Dialog.Title>{title}</Dialog.Title>}
        <Dialog.Content style={contentStyle}>
          {typeof message === 'string' ? <Text>{message}</Text> : message}
        </Dialog.Content>
        <Dialog.Actions>
          {onCancel && <Button onPress={onCancel}>{cancelText}</Button>}
          <Button onPress={onConfirm}>{confirmText}</Button>
        </Dialog.Actions>
      </Dialog>
    </Portal>
  );
}
