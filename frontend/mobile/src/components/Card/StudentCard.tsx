import dayjs from 'dayjs';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { EntityCard } from './EntityCard';

type StudentStatus =
  components['schemas']['StudentOverviewResponse']['statuses'][number];

type Props = {
  student: components['schemas']['StudentOverviewResponse'];
};

export const StudentCard = ({ student }: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const badges = useMemo(() => {
    const statusConfig: Record<
      StudentStatus,
      { label: string; bg: string; text: string }
    > = {
      INACTIVE: {
        label: 'inactive',
        bg: theme.colors.primary,
        text: theme.colors.onPrimary
      },
      PRESENT: {
        label: 'present',
        bg: theme.colors.secondaryContainer,
        text: theme.colors.onSecondaryContainer
      },
      MISSING: {
        label: 'missing',
        bg: theme.colors.errorContainer,
        text: theme.colors.onErrorContainer
      },
      PAID: {
        label: 'paid',
        bg: theme.colors.secondaryContainer,
        text: theme.colors.onSecondaryContainer
      },
      UNPAID: {
        label: 'unpaid',
        bg: theme.colors.tertiary,
        text: theme.colors.onTertiary
      }
    };

    return Object.entries(statusConfig)
      .filter(([status]) => student.statuses.includes(status as StudentStatus))
      .map(([status, config]) => ({
        id: status,
        label: t(`studentStatus.${config.label}`),
        backgroundColor: config.bg,
        textColor: config.text
      }));
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
