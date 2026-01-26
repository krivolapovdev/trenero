import dayjs from 'dayjs';
import { nanoid } from 'nanoid/non-secure';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { EntityCard } from './EntityCard';

type Props = {
  student: components['schemas']['StudentOverviewResponse'];
};

export const StudentCard = ({ student }: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const badges = useMemo(() => {
    const result = [];

    if (student.statuses?.includes('INACTIVE')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.inactive'),
        backgroundColor: theme.colors.primary,
        textColor: theme.colors.onPrimary
      });
      return result;
    }

    if (student?.statuses?.includes('PRESENT')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.present'),
        backgroundColor: theme.colors.secondaryContainer,
        textColor: theme.colors.onSecondaryContainer
      });
    }

    if (student.statuses?.includes('MISSING')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.missing'),
        backgroundColor: theme.colors.errorContainer,
        textColor: theme.colors.onErrorContainer
      });
    }

    if (student.statuses?.includes('PAID')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.paid'),
        backgroundColor: theme.colors.secondaryContainer,
        textColor: theme.colors.onSecondaryContainer
      });
    }

    if (student.statuses?.includes('UNPAID')) {
      result.push({
        id: nanoid(),
        label: t('studentStatus.unpaid'),
        backgroundColor: theme.colors.tertiary,
        textColor: theme.colors.onTertiary
      });
    }

    return result;
  }, [student.statuses, theme, t]);

  const subtitle = [
    student.studentGroup && `${t('group')}: ${student.studentGroup.name}`,
    student.phone && `${t('phone')}: ${student.phone}`,
    student.birthdate &&
      `${t('birthdate')}: ${dayjs(student.birthdate).format('DD/MM/YYYY')}`,
    student.note && `${t('note')}: ${student.note}`
  ]
    .filter(Boolean)
    .join('\n');

  return (
    <EntityCard
      title={student.fullName}
      subtitle={subtitle}
      href={`/(tabs)/students/${student.id}`}
      badges={badges}
    />
  );
};
