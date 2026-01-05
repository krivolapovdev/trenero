import { nanoid } from 'nanoid/non-secure';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { EntityCard } from './EntityCard';

type Props = GetStudentsQuery['students'][number] & {
  subtitle: string;
};

export const StudentCard = ({
  id,
  fullName,
  lastAttendance,
  subtitle
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
              : theme.colors.errorContainer,
            textColor: lastAttendance.present
              ? theme.colors.inversePrimary
              : theme.colors.onErrorContainer
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
      backgroundColor: theme.colors.tertiary,
      textColor: theme.colors.onTertiary
    }
  ];

  return (
    <EntityCard
      title={fullName}
      subtitle={subtitle}
      href={`/(tabs)/students/${id}`}
      badges={badges}
    />
  );
};
