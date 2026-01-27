import {
  type Dispatch,
  memo,
  type SetStateAction,
  useCallback,
  useEffect,
  useMemo
} from 'react';
import { useTranslation } from 'react-i18next';
import { View } from 'react-native';
import { Button, Switch, Text } from 'react-native-paper';
import type { components } from '@/src/api/generated/openapi';

type Props = {
  students: components['schemas']['StudentResponse'][];
  visitStatus: Record<string, boolean>;
  setVisitStatus: Dispatch<SetStateAction<Record<string, boolean>>>;
  disabled?: boolean;
};

export const StudentVisitPicker = memo(
  ({
    students,
    visitStatus,
    setVisitStatus,
    disabled = false
  }: Readonly<Props>) => {
    const { t } = useTranslation();

    const anyPresent = useMemo(
      () => Object.values(visitStatus).some(Boolean),
      [visitStatus]
    );

    const selectAll = useCallback(() => {
      setVisitStatus(
        Object.fromEntries(students.map(student => [student.id, true]))
      );
    }, [setVisitStatus, students.map]);

    const unselectAll = useCallback(() => {
      setVisitStatus(
        Object.fromEntries(students.map(student => [student.id, false]))
      );
    }, [setVisitStatus, students.map]);

    useEffect(() => {
      setVisitStatus((prev: Record<string, boolean>) => {
        if (Object.keys(prev).length === 0 && students.length > 0) {
          return Object.fromEntries(
            students.map(student => [student.id, false])
          );
        }
        return prev;
      });
    }, [students, setVisitStatus]);

    if (students.length === 0) {
      return <Text>{t('noStudentsFound')}</Text>;
    }

    return (
      <View style={{ gap: 8 }}>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: 8
          }}
        >
          <Text style={{ fontSize: 16 }}>{t('students')}</Text>

          <Button
            mode='text'
            onPress={anyPresent ? unselectAll : selectAll}
            disabled={disabled}
          >
            {anyPresent ? t('unselectAll') : t('selectAll')}
          </Button>
        </View>

        {students.map(student => (
          <View
            key={student.id}
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
              paddingVertical: 8
            }}
          >
            <Text>{student.fullName}</Text>

            <Switch
              value={visitStatus[student.id] ?? false}
              style={{ padding: 0 }}
              disabled={disabled}
              onValueChange={value =>
                setVisitStatus(prev => ({ ...prev, [student.id]: value }))
              }
            />
          </View>
        ))}
      </View>
    );
  }
);
