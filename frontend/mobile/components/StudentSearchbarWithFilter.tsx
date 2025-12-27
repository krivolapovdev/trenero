import { useQuery } from '@apollo/client/react';
import {
  BottomSheetBackdrop,
  type BottomSheetBackdropProps,
  BottomSheetModal,
  BottomSheetScrollView
} from '@gorhom/bottom-sheet';
import { memo, useCallback, useMemo, useRef, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { Button, Text } from 'react-native-paper';
import { FilterAccordion } from '@/components/FilterAccordion';
import { SearchbarWithFilter } from '@/components/SearchbarWithFilter';
import { GET_GROUPS } from '@/graphql/quries';
import type { Group } from '@/graphql/types';
import { useAppTheme } from '@/hooks/useAppTheme';

type ExpandedAccordion = 'group' | 'status' | null;

const STATUSES = ['All', 'Attending', 'Paid'] as const;
type Status = (typeof STATUSES)[number];

type Props = {
  value: string;
  onChange: (query: string) => void;
  onClearIconPress: () => void;
  onFilter: (filters: { group: string; status: Status }) => void;
};

export const StudentSearchbarWithFilter = memo(
  ({ value, onChange, onClearIconPress, onFilter }: Readonly<Props>) => {
    const theme = useAppTheme();
    const bottomSheetModalRef = useRef<BottomSheetModal>(null);

    const [expandedAccordion, setExpandedAccordion] =
      useState<ExpandedAccordion>(null);

    const [appliedGroup, setAppliedGroup] = useState<string>('All');
    const [appliedStatus, setAppliedStatus] = useState<Status>('All');

    const [selectedGroup, setSelectedGroup] = useState<string>('All');
    const [selectedStatus, setSelectedStatus] = useState<Status>('All');

    const { data } = useQuery<{ groups: Group[] }>(GET_GROUPS, {
      fetchPolicy: 'cache-first'
    });

    const groups = data?.groups ?? [];

    const groupItems = useMemo(
      () => ['All', ...groups.map(group => group.name)],
      [groups]
    );

    const handleOpenModal = useCallback(() => {
      setSelectedGroup(appliedGroup);
      setSelectedStatus(appliedStatus);
      bottomSheetModalRef.current?.present();
    }, [appliedGroup, appliedStatus]);

    const handleDismiss = useCallback(() => {
      setExpandedAccordion(null);
    }, []);

    const toggleAccordion = useCallback(
      (key: ExpandedAccordion) =>
        setExpandedAccordion(prev => (prev === key ? null : key)),
      []
    );

    const handleCloseModal = useCallback(() => {
      setExpandedAccordion(null);
      bottomSheetModalRef.current?.dismiss();
    }, []);

    const handleApply = useCallback(() => {
      setAppliedGroup(selectedGroup);
      setAppliedStatus(selectedStatus);
      onFilter({ group: selectedGroup, status: selectedStatus });
      handleCloseModal();
    }, [onFilter, selectedGroup, selectedStatus, handleCloseModal]);

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
          onClearIconPress={onClearIconPress}
          onFilterPress={handleOpenModal}
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

            <View style={styles.filter}>
              <FilterAccordion
                title='Group'
                items={groupItems}
                selectedItem={selectedGroup}
                expanded={expandedAccordion === 'group'}
                onPress={() => toggleAccordion('group')}
                onSelect={setSelectedGroup}
              />

              <FilterAccordion
                title='Status'
                items={STATUSES}
                selectedItem={selectedStatus}
                expanded={expandedAccordion === 'status'}
                onPress={() => toggleAccordion('status')}
                onSelect={setSelectedStatus}
              />
            </View>

            <View style={styles.footer}>
              <Button
                mode='contained-tonal'
                buttonColor={theme.colors.surface}
                textColor={theme.colors.onSurface}
                onPress={handleApply}
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
    gap: 12
  },
  filter: {
    gap: 12
  }
});
