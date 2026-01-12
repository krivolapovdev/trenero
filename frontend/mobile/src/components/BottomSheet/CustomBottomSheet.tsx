import {
  BottomSheetBackdrop,
  type BottomSheetBackdropProps,
  BottomSheetModal,
  BottomSheetScrollView
} from '@gorhom/bottom-sheet';
import { type ReactNode, useCallback, useEffect, useRef } from 'react';
import { StyleSheet } from 'react-native';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = {
  visible: boolean;
  onDismiss: () => void;
  children: ReactNode;
};

export const CustomBottomSheet = ({
  visible,
  onDismiss,
  children
}: Readonly<Props>) => {
  const theme = useAppTheme();
  const bottomSheetRef = useRef<BottomSheetModal>(null);

  const renderBackdrop = useCallback(
    (props: BottomSheetBackdropProps) => (
      <BottomSheetBackdrop
        {...props}
        disappearsOnIndex={-1}
        appearsOnIndex={0}
      />
    ),
    []
  );

  useEffect(() => {
    if (visible) {
      bottomSheetRef.current?.present();
    } else {
      bottomSheetRef.current?.dismiss();
    }
  }, [visible]);

  return (
    <BottomSheetModal
      ref={bottomSheetRef}
      index={0}
      backdropComponent={renderBackdrop}
      backgroundStyle={{ backgroundColor: theme.colors.surfaceVariant }}
      onDismiss={onDismiss}
    >
      <BottomSheetScrollView
        contentContainerStyle={styles.contentContainer}
        keyboardShouldPersistTaps='handled'
      >
        {children}
      </BottomSheetScrollView>
    </BottomSheetModal>
  );
};

const styles = StyleSheet.create({
  contentContainer: {
    padding: 24,
    paddingTop: 0,
    gap: 12
  }
});
