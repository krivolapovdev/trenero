import { nanoid } from 'nanoid/non-secure';
import { EntityCard } from '@/src/components/EntityCard';
import type { Student } from '@/src/graphql/types';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = Student;

export const StudentItem = ({ id, fullName, group }: Readonly<Props>) => {
  const theme = useAppTheme();

  const isPaid = true;

  const badges = [
    {
      id: nanoid(),
      label: 'Ходит',
      backgroundColor: theme.colors.green,
      textColor: theme.colors.onSecondaryContainer
    },
    {
      id: nanoid(),
      label: 'Не оплатил',
      backgroundColor: theme.colors.errorContainer,
      textColor: theme.colors.onErrorContainer,
      isVisible: !isPaid
    }
  ];

  return (
    <EntityCard
      title={fullName}
      subtitle={group?.name ?? 'Unassigned'}
      href={`/(tabs)/students/${id}`}
      badges={badges}
    />
  );
};
