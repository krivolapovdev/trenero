import {
  BottomSheetBackdrop,
  type BottomSheetBackdropProps,
  BottomSheetModal,
  BottomSheetScrollView
} from '@gorhom/bottom-sheet';
import { memo, useCallback, useRef, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { Button, Text } from 'react-native-paper';
import { FilterAccordion } from '@/components/FilterAccordion';
import { SearchbarWithFilter } from '@/components/SearchbarWithFilter';
import { useAppTheme } from '@/hooks/useAppTheme';
import { useAppStore } from '@/stores/appStore';

const STATUSES = ['All', 'Attending', 'Paid'] as const;
type Status = (typeof STATUSES)[number];

type Props = {
  value: string;
  onChange: (query: string) => void;
  onClear: () => void;
  onFilter: (filters: { group: string; status: Status }) => void;
};

export const StudentSearchbarWithFilter = memo(
  ({ value, onChange, onClear, onFilter }: Readonly<Props>) => {
    const theme = useAppTheme();
    const groups = useAppStore(state => state.groups);
    const bottomSheetModalRef = useRef<BottomSheetModal>(null);

    const [showGroupAccordion, setShowGroupAccordion] = useState(false);
    const [selectedGroup, setSelectedGroup] = useState<string>('All');

    const [showStatusAccordion, setShowStatusAccordion] = useState(false);
    const [selectedStatus, setSelectedStatus] = useState<Status>('All');

    const handleDismiss = useCallback(() => {
      setShowGroupAccordion(false);
      setShowStatusAccordion(false);
    }, []);

    const handleCloseModal = useCallback(() => {
      bottomSheetModalRef.current?.dismiss();
    }, []);

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

    return (
      <>
        <SearchbarWithFilter
          value={value}
          onChange={onChange}
          onClear={onClear}
          onFilterPress={() => bottomSheetModalRef.current?.present()}
        />

        <BottomSheetModal
          ref={bottomSheetModalRef}
          index={0}
          backdropComponent={renderBackdrop}
          backgroundStyle={{ backgroundColor: theme.colors.surfaceVariant }}
          onDismiss={handleDismiss}
        >
          <BottomSheetScrollView
            contentContainerStyle={styles.contentContainer}
          >
            <Text variant='titleLarge'>Filter</Text>

            <View style={{ gap: 12 }}>
              <FilterAccordion
                title='Group'
                items={['All', ...groups.map(g => g.name)]}
                selectedItem={selectedGroup}
                expanded={showGroupAccordion}
                onPress={() => setShowGroupAccordion(prev => !prev)}
                onSelect={setSelectedGroup}
              />

              <FilterAccordion
                title='Status'
                items={STATUSES}
                selectedItem={selectedStatus}
                expanded={showStatusAccordion}
                onPress={() => setShowStatusAccordion(prev => !prev)}
                onSelect={setSelectedStatus}
              />
            </View>

            <View style={styles.footer}>
              <Button
                mode='contained-tonal'
                buttonColor={theme.colors.surface}
                textColor={theme.colors.onSurface}
                onPress={handleCloseModal}
              >
                Clear
              </Button>

              <Button
                mode='contained-tonal'
                buttonColor={theme.colors.surface}
                textColor={theme.colors.onSurface}
                onPress={() => {
                  onFilter({ group: selectedGroup, status: selectedStatus });
                  handleCloseModal();
                }}
              >
                Apply
              </Button>
            </View>
          </BottomSheetScrollView>
        </BottomSheetModal>
      </>
    );
  }
);

const styles = StyleSheet.create({
  contentContainer: {
    padding: 24,
    gap: 20
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 12,
    marginVertical: 8
  }
});
