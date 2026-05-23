import dayjs from 'dayjs';
import { useTranslation } from 'react-i18next';
import type { components } from '@/src/api/generated/openapi';
import { useStudentBadges } from '@/src/hooks/useStudentBadges';
import { EntityCard } from './EntityCard';

type Props = {
  student: components['schemas']['StudentOverviewResponse'];
};

export const StudentCard = ({ student }: Readonly<Props>) => {
  const { t } = useTranslation();
  const badges = useStudentBadges(student.statuses);

  const subtitle = [
    student.studentGroup && `${t('group')}: ${student.studentGroup.name}`,
    student.phone && `${t('phone')}: ${student.phone}`,
    student.birthdate &&
      `${t('birthdate')}: ${dayjs(student.birthdate).format('DD.MM.YYYY')}`,
    student.note && `${t('note')}: ${student.note}`
  ]
    .filter(Boolean)
    .join('\n');

  return (
    <EntityCard
      title={student.fullName}
      subtitle={subtitle}
      href={`/(tabs)/students/${student.id}`}
      badges={badges}
    />
  );
};
