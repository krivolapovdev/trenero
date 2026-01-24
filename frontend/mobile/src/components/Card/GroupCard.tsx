import { useTranslation } from 'react-i18next';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { EntityCard } from './EntityCard';

type Props = components['schemas']['GroupResponse'];

export const GroupCard = ({
  id,
  name,
  defaultPrice,
  note
  // students
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const _theme = useAppTheme();

  // const badges = [
  //   {
  //     id: nanoid(),
  //     label: `${t('students')}: ${students?.length ?? 0} `,
  //     backgroundColor: theme.colors.secondaryContainer,
  //     textColor: theme.colors.onSecondaryContainer
  //   }
  // ];

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
      // badges={badges}
    />
  );
};
