import dayjs from 'dayjs';
import { nanoid } from 'nanoid/non-secure';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import { getStudentStatuses } from '@/src/helpers/getStudentStatuses';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { EntityCard } from './EntityCard';

type Props = GetStudentsQuery['students'][number];

export const StudentCard = ({
  id,
  fullName,
  group,
  phone,
  birthdate,
  note,
  ...student
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();
  const statuses = getStudentStatuses(student);

  const badges = useMemo(() => {
    const result = [];

    if (statuses.has('no_activity')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.no_activity'),
        backgroundColor: theme.colors.primary,
        textColor: theme.colors.onPrimary
      });
      return result;
    }

    if (statuses.has('present')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.present'),
        backgroundColor: theme.colors.secondaryContainer,
        textColor: theme.colors.onSecondaryContainer
      });
    }

    if (statuses.has('missing')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.missing'),
        backgroundColor: theme.colors.errorContainer,
        textColor: theme.colors.onErrorContainer
      });
    }

    if (statuses.has('paid')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.paid'),
        backgroundColor: theme.colors.secondaryContainer,
        textColor: theme.colors.onSecondaryContainer
      });
    }

    if (statuses.has('unpaid')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.unpaid'),
        backgroundColor: theme.colors.tertiary,
        textColor: theme.colors.onTertiary
      });
    }

    return result;
  }, [statuses, theme, t]);

  const subtitle = [
    group && `${t('groupLabel')}: ${group?.name ?? t('unassigned')}`,
    phone && `${t('phoneLabel')}: ${phone}`,
    birthdate &&
      `${t('birthdateLabel')}: ${dayjs(birthdate).format('DD/MM/YYYY')}`,
    note && `${t('noteLabel')}: ${note}`
  ]
    .filter(Boolean)
    .join('\n');

  return (
    <EntityCard
      title={fullName}
      subtitle={subtitle}
      href={`/(tabs)/students/${id}`}
      badges={badges}
    />
  );
};
