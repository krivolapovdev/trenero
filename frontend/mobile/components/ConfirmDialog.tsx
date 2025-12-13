import type { ViewStyle } from 'react-native';
import { Button, Dialog, Portal, Text } from 'react-native-paper';

type Props = {
  visible: boolean;
  title?: string;
  message: string;
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
}: Props) {
  return (
    <Portal>
      <Dialog
        visible={visible}
        onDismiss={onCancel}
      >
        {title && <Dialog.Title>{title}</Dialog.Title>}
        <Dialog.Content style={contentStyle}>
          <Text>{message}</Text>
        </Dialog.Content>
        <Dialog.Actions>
          <Button onPress={onCancel}>{cancelText}</Button>
          <Button onPress={onConfirm}>{confirmText}</Button>
        </Dialog.Actions>
      </Dialog>
    </Portal>
  );
}
