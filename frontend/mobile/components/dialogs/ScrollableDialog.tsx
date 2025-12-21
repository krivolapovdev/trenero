import { memo, type ReactNode } from 'react';
import { ScrollView, useWindowDimensions } from 'react-native';
import { Button, Dialog, Portal } from 'react-native-paper';

type Props = {
  visible: boolean;
  title?: string;
  children: ReactNode;
  onDismiss: () => void;
  onConfirm?: () => void;
  onCancel?: () => void;
  confirmText?: string;
  cancelText?: string;
};

export const ScrollableDialog = memo(
  ({
    visible,
    title,
    children,
    onDismiss,
    onConfirm,
    onCancel,
    confirmText = 'OK',
    cancelText = 'Cancel'
  }: Readonly<Props>) => {
    const { height } = useWindowDimensions();
    return (
      <Portal>
        <Dialog
          visible={visible}
          onDismiss={onDismiss}
          style={{ maxHeight: 0.7 * height }}
        >
          {title && <Dialog.Title>{title}</Dialog.Title>}

          <Dialog.ScrollArea>
            <ScrollView
              contentContainerStyle={{ paddingVertical: 16 }}
              showsVerticalScrollIndicator={false}
            >
              {children}
            </ScrollView>
          </Dialog.ScrollArea>

          <Dialog.Actions>
            {onCancel && <Button onPress={onCancel}>{cancelText}</Button>}
            {onConfirm && <Button onPress={onConfirm}>{confirmText}</Button>}
          </Dialog.Actions>
        </Dialog>
      </Portal>
    );
  }
);
