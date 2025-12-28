import { nanoid } from 'nanoid/non-secure';
import { EntityCard } from '@/src/components/EntityCard';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = GetStudentsQuery['students'][number];

export const StudentItem = ({
  id,
  fullName,
  group,
  lastAttendance
}: Readonly<Props>) => {
  const theme = useAppTheme();

  const badges = [
    ...(lastAttendance
      ? [
          {
            id: nanoid(),
            label: lastAttendance.present ? 'Present' : 'Missing',
            backgroundColor: lastAttendance.present
              ? theme.colors.green
              : theme.colors.error,
            textColor: lastAttendance.present
              ? theme.colors.inversePrimary
              : theme.colors.onPrimaryContainer
          }
        ]
      : [
          {
            id: nanoid(),
            label: 'No Activity',
            backgroundColor: theme.colors.secondaryContainer,
            textColor: theme.colors.onSecondaryContainer
          }
        ]),
    {
      id: nanoid(),
      label: 'Не оплатил',
      backgroundColor: theme.colors.errorContainer,
      textColor: theme.colors.onErrorContainer
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
