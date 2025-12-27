import { nanoid } from 'nanoid/non-secure';
import { EntityCard } from '@/components/EntityCard';
import type { Group } from '@/graphql/types';
import { useAppTheme } from '@/hooks/useAppTheme';

type Props = Group;

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
      label: `${students?.length ?? 0} студентов`,
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
