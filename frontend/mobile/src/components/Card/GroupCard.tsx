import {nanoid} from 'nanoid/non-secure';
import type {GetGroupsQuery} from '@/src/graphql/__generated__/graphql';
import {useAppTheme} from '@/src/hooks/useAppTheme';
import {EntityCard} from './EntityCard';

type Props = GetGroupsQuery['groups'][number];

export const GroupCard = ({
  id,
  name,
                            defaultPrice,
                            note,
                            students
}: Readonly<Props>) => {
  const theme = useAppTheme();

  const badges = [
    {
      id: nanoid(),
      label: `${students?.length ?? 0} students`,
      backgroundColor: theme.colors.secondaryContainer,
      textColor: theme.colors.onSecondaryContainer
    }
  ];

  const subtitle = [
    defaultPrice && `Default price: ${defaultPrice}`,
    note && `Note: ${note}`
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
