import { nanoid } from 'nanoid/non-secure';
import { EntityCard } from '@/src/components/EntityCard';
import type { GetGroupsQuery } from '@/src/graphql/__generated__/graphql';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = GetGroupsQuery['groups'][number];

export const GroupItem = ({
  id,
  name,
  defaultPrice,
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

  return (
    <EntityCard
      title={name}
      subtitle={defaultPrice}
      href={`/(tabs)/groups/${id}`}
      badges={badges}
    />
  );
};
