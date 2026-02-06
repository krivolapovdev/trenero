import { memo, useCallback, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { StyleSheet, View } from 'react-native';
import { Button, Text } from 'react-native-paper';
import type { components } from '@/src/api/generated/openapi';
import { CustomBottomSheet } from '@/src/components/BottomSheet/CustomBottomSheet';
import { SearchbarWithFilter } from '@/src/components/Searchbar/SearchbarWithFilter';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import type { StudentStatus } from '@/src/types/student';
import { FilterAccordion } from './FilterAccordion';

const ALL_ITEM = { id: 'All', name: 'All' };

type ExpandedAccordion = 'group' | 'status' | null;

type Props = {
  value: string;
  onChange: (query: string) => void;
  onClearIconPress: () => void;

  filterGroup: string | null;
  setFilterGroup: (group: string | null) => void;

  filterStatus: StudentStatus | null;
  setFilterStatus: (status: StudentStatus | null) => void;

  groupsRecord: Record<string, components['schemas']['GroupOverviewResponse']>;
};

export const StudentSearchbarWithFilter = memo(
  ({
    value,
    onChange,
    onClearIconPress,
    filterGroup,
    setFilterGroup,
    filterStatus,
    setFilterStatus,
    groupsRecord
  }: Readonly<Props>) => {
    const { t } = useTranslation();
    const theme = useAppTheme();

    const [visible, setVisible] = useState(false);
    const [expandedAccordion, setExpandedAccordion] =
      useState<ExpandedAccordion>(null);

    const [draftGroup, setDraftGroup] = useState<string | null>(null);
    const [draftStatus, setDraftStatus] = useState<StudentStatus | null>(null);

    const groupItems = useMemo(
      () => [
        ALL_ITEM,
        ...Object.values(groupsRecord).map(group => ({
          id: group.id,
          name: group.name
        }))
      ],
      [groupsRecord]
    );

    const statusItems = useMemo(
      () => [
        ALL_ITEM,
        { id: 'inactive', name: t('studentStatus.inactive') },
        { id: 'present', name: t('studentStatus.present') },
        { id: 'missing', name: t('studentStatus.missing') },
        { id: 'paid', name: t('studentStatus.paid') },
        { id: 'unpaid', name: t('studentStatus.unpaid') }
      ],
      [t]
    );

    const handleOpen = useCallback(() => {
      setDraftGroup(filterGroup);
      setDraftStatus(filterStatus);
      setVisible(true);
    }, [filterGroup, filterStatus]);

    const handleDismiss = useCallback(() => {
      setExpandedAccordion(null);
      setVisible(false);
    }, []);

    const toggleAccordion = useCallback(
      (key: ExpandedAccordion) =>
        setExpandedAccordion(prev => (prev === key ? null : key)),
      []
    );

    const handleClear = useCallback(() => {
      setFilterGroup(null);
      setFilterStatus(null);
      handleDismiss();
    }, [handleDismiss, setFilterGroup, setFilterStatus]);

    const handleApply = useCallback(() => {
      setFilterGroup(draftGroup);
      setFilterStatus(draftStatus);
      handleDismiss();
    }, [
      handleDismiss,
      draftGroup,
      draftStatus,
      setFilterGroup,
      setFilterStatus
    ]);

    return (
      <>
        <SearchbarWithFilter
          value={value}
          onChange={onChange}
          onClearIconPress={onClearIconPress}
          onFilterPress={handleOpen}
          hasActiveFilters={Boolean(filterGroup) || Boolean(filterStatus)}
        />

        <CustomBottomSheet
          visible={visible}
          onDismiss={handleDismiss}
        >
          <Text variant='titleLarge'>Filter</Text>

          <View style={styles.filter}>
            <FilterAccordion
              title='Group'
              items={groupItems}
              selectedItem={draftGroup ?? 'All'}
              expanded={expandedAccordion === 'group'}
              onPress={() => toggleAccordion('group')}
              onSelect={g => setDraftGroup(g === 'All' ? null : g)}
            />

            <FilterAccordion
              title='Status'
              items={statusItems}
              selectedItem={draftStatus ?? 'All'}
              expanded={expandedAccordion === 'status'}
              onPress={() => toggleAccordion('status')}
              onSelect={s =>
                setDraftStatus(s === 'All' ? null : (s as StudentStatus))
              }
            />
          </View>

          <View style={styles.footer}>
            <Button
              mode='contained-tonal'
              buttonColor={theme.colors.surface}
              textColor={theme.colors.onSurface}
              onPress={handleClear}
            >
              Clear
            </Button>

            <Button
              mode='contained-tonal'
              buttonColor={theme.colors.surface}
              textColor={theme.colors.onSurface}
              onPress={handleApply}
            >
              Apply
            </Button>
          </View>
        </CustomBottomSheet>
      </>
    );
  }
);

const styles = StyleSheet.create({
  filter: {
    rowGap: 12
  },
  footer: {
    flexDirection: 'row',
    columnGap: 12,
    justifyContent: 'flex-end',
    marginBottom: 10
  }
});
