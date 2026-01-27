import { nanoid } from 'nanoid/non-secure';
import { useTranslation } from 'react-i18next';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { EntityCard } from './EntityCard';

type Props = components['schemas']['GroupOverviewResponse'];

export const GroupCard = ({
  id,
  name,
  defaultPrice,
  note,
  studentsCount
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const badges = [
    {
      id: nanoid(),
      label: `${t('students')}: ${studentsCount}`,
      backgroundColor: theme.colors.secondaryContainer,
      textColor: theme.colors.onSecondaryContainer
    }
  ];

  const subtitle = [
    defaultPrice && `${t('defaultPrice')}: ${defaultPrice}`,
    note && `${t('note')}: ${note}`
  ]
    .filter(Boolean)
    .join('\n');

  return (
    <EntityCard
      title={name}
      subtitle={subtitle}
      href={`/(tabs)/groups/${id}`}
      badges={badges}
    />
  );
};
