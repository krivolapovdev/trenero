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
import { Button, IconButton, Text, TouchableRipple } from 'react-native-paper';
import type { components } from '@/src/api/generated/openapi';
import {
  type VisitStatus,
  VisitStatusColor,
  VisitStatusIcon
} from '@/src/types/visit';

const STATUS_ORDER: VisitStatus[] = ['UNMARKED', 'PRESENT', 'ABSENT', 'FREE'];

type Props = {
  students: components['schemas']['StudentResponse'][];
  visitStatus: Record<string, VisitStatus>;
  setVisitStatus: Dispatch<SetStateAction<Record<string, VisitStatus>>>;
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

    const hasMarked = useMemo(
      () =>
        Object.values(visitStatus).some(
          status => status !== 'UNMARKED' && status !== 'ABSENT'
        ),
      [visitStatus]
    );

    const selectAll = useCallback(() => {
      setVisitStatus(
        Object.fromEntries(students.map(student => [student.id, 'PRESENT']))
      );
    }, [setVisitStatus, students.map]);

    const unselectAll = useCallback(() => {
      setVisitStatus(
        Object.fromEntries(students.map(student => [student.id, 'ABSENT']))
      );
    }, [setVisitStatus, students.map]);

    const toggleStatus = useCallback(
      (studentId: string) => {
        if (disabled) {
          return;
        }

        setVisitStatus(prev => {
          const currentStatus = prev[studentId] ?? 'UNMARKED';
          const currentIndex = STATUS_ORDER.indexOf(currentStatus);
          const nextIndex = (currentIndex + 1) % STATUS_ORDER.length;
          return { ...prev, [studentId]: STATUS_ORDER[nextIndex] };
        });
      },
      [disabled, setVisitStatus]
    );

    useEffect(() => {
      setVisitStatus(prev => {
        if (Object.keys(prev).length === 0 && students.length > 0) {
          return Object.fromEntries(students.map(s => [s.id, 'UNMARKED']));
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
            onPress={hasMarked ? unselectAll : selectAll}
            disabled={disabled}
          >
            {hasMarked ? t('unselectAll') : t('selectAll')}
          </Button>
        </View>

        {students.map(student => {
          const status = visitStatus[student.id] ?? 'UNMARKED';
          const isUnmarked = status === 'UNMARKED';

          return (
            <TouchableRipple
              key={student.id}
              onPress={() => toggleStatus(student.id)}
              disabled={disabled}
              rippleColor='rgba(0, 0, 0, .05)'
              style={{ borderRadius: 8 }}
            >
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  paddingLeft: 12,
                  height: 52
                }}
              >
                <Text
                  variant='bodyLarge'
                  style={[
                    { flex: 1, fontSize: 16 },
                    isUnmarked && {
                      textDecorationLine: 'line-through',
                      opacity: 0.5
                    }
                  ]}
                  numberOfLines={1}
                >
                  {student.fullName}
                </Text>

                <IconButton
                  icon={VisitStatusIcon[status]}
                  iconColor={VisitStatusColor[status]}
                  size={28}
                  style={{ margin: 0 }}
                />
              </View>
            </TouchableRipple>
          );
        })}
      </View>
    );
  }
);
