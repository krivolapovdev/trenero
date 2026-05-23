import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type StudentStatus =
  components['schemas']['StudentOverviewResponse']['statuses'][number];

export const useStudentBadges = (statuses: StudentStatus[]) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  return useMemo(() => {
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
      .filter(([status]) => statuses.includes(status as StudentStatus))
      .map(([status, config]) => ({
        id: status,
        label: t(`studentStatus.${config.label}`),
        backgroundColor: config.bg,
        textColor: config.text
      }));
  }, [statuses, theme, t]);
};
