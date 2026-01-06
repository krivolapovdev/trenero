import {nanoid} from 'nanoid/non-secure';
import {useMemo} from 'react';
import type {GetStudentsQuery} from '@/src/graphql/__generated__/graphql';
import {getStudentStatuses} from '@/src/helpers/getStudentStatuses';
import {useAppTheme} from '@/src/hooks/useAppTheme';
import {STUDENT_STATUS_LABEL} from '@/src/types/student';
import {EntityCard} from './EntityCard';

type Props = GetStudentsQuery['students'][number] & {
  subtitle: string;
};

export const StudentCard = ({
  id,
  fullName,
                              subtitle,
                              ...student
}: Readonly<Props>) => {
  const theme = useAppTheme();
  const statuses = useMemo(() => getStudentStatuses(student), [student]);

  const badges = useMemo(() => {
    const result = [];

    if (statuses.has('no_activity')) {
      result.push({
        id: nanoid(),
        label: STUDENT_STATUS_LABEL['no_activity'],
        backgroundColor: theme.colors.primary,
        textColor: theme.colors.onPrimary
      });
      return result;
    }

    if (statuses.has('present')) {
      result.push({
        id: nanoid(),
        label: STUDENT_STATUS_LABEL['present'],
        backgroundColor: theme.colors.secondaryContainer,
        textColor: theme.colors.onSecondaryContainer
      });
    }

    if (statuses.has('missing')) {
      result.push({
        id: nanoid(),
        label: STUDENT_STATUS_LABEL['missing'],
        backgroundColor: theme.colors.errorContainer,
        textColor: theme.colors.onErrorContainer
      });
    }

    if (statuses.has('paid')) {
      result.push({
        id: nanoid(),
        label: STUDENT_STATUS_LABEL['paid'],
        backgroundColor: theme.colors.secondaryContainer,
        textColor: theme.colors.onSecondaryContainer
      });
    }

    if (statuses.has('unpaid')) {
      result.push({
        id: nanoid(),
        label: STUDENT_STATUS_LABEL['unpaid'],
        backgroundColor: theme.colors.tertiary,
        textColor: theme.colors.onTertiary
      });
    }

    return result;
  }, [statuses, theme]);

  return (
    <EntityCard
      title={fullName}
      subtitle={subtitle}
      href={`/(tabs)/students/${id}`}
      badges={badges}
    />
  );
};
