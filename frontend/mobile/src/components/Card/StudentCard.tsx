import dayjs from 'dayjs';
import { useTranslation } from 'react-i18next';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { EntityCard } from './EntityCard';

type Props = components['schemas']['StudentResponse'];

export const StudentCard = ({
  id,
  fullName,
  // group,
  phone,
  birthdate,
  note
  // payments,
  // visits
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const _theme = useAppTheme();
  // const statuses = getStudentStatuses(visits, payments);
  //
  // const badges = useMemo(() => {
  //   const result = [];
  //
  //   if (statuses.has('noActivity')) {
  //     result.push({
  //       id: nanoid(),
  //       label: t('studentStatus.noActivity'),
  //       backgroundColor: theme.colors.primary,
  //       textColor: theme.colors.onPrimary
  //     });
  //     return result;
  //   }
  //
  //   if (statuses.has('present')) {
  //     result.push({
  //       id: nanoid(),
  //       label: t('studentStatus.present'),
  //       backgroundColor: theme.colors.secondaryContainer,
  //       textColor: theme.colors.onSecondaryContainer
  //     });
  //   }
  //
  //   if (statuses.has('missing')) {
  //     result.push({
  //       id: nanoid(),
  //       label: t('studentStatus.missing'),
  //       backgroundColor: theme.colors.errorContainer,
  //       textColor: theme.colors.onErrorContainer
  //     });
  //   }
  //
  //   if (statuses.has('paid')) {
  //     result.push({
  //       id: nanoid(),
  //       label: t('studentStatus.paid'),
  //       backgroundColor: theme.colors.secondaryContainer,
  //       textColor: theme.colors.onSecondaryContainer
  //     });
  //   }
  //
  //   if (statuses.has('unpaid')) {
  //     result.push({
  //       id: nanoid(),
  //       label: t('studentStatus.unpaid'),
  //       backgroundColor: theme.colors.tertiary,
  //       textColor: theme.colors.onTertiary
  //     });
  //   }
  //
  //   return result;
  // }, [statuses, theme, t]);

  const subtitle = [
    // group && `${t('groupLabel')}: ${group?.name ?? t('unassigned')}`,
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
      // badges={badges}
    />
  );
};
