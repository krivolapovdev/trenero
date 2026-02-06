import {
  type Dispatch,
  memo,
  type SetStateAction,
  useCallback,
  useEffect,
  useMemo,
  useState
} from 'react';
import { useTranslation } from 'react-i18next';
import { Pressable, View } from 'react-native';
import { Button, Checkbox, RadioButton, Text } from 'react-native-paper';
import type { components } from '@/src/api/generated/openapi';
import { CustomBottomSheet } from '@/src/components/BottomSheet';
import type { VisitStatus, VisitType } from '@/src/types/visit';

const getCheckboxStatus = (status: VisitStatus) => {
  switch (status) {
    case 'PRESENT':
      return 'checked';
    case 'UNMARKED':
      return 'indeterminate';
    default:
      return 'unchecked';
  }
};

const VISIT_OPTIONS: { value: VisitType; label: string }[] = [
  { value: 'REGULAR', label: 'visitType.regular' },
  { value: 'FREE', label: 'visitType.free' },
  { value: 'UNMARKED', label: 'visitType.unmarked' }
];

export type StudentVisitState = {
  status: VisitStatus;
  type: VisitType;
};

type Props = {
  students: components['schemas']['StudentResponse'][];
  visitState: Record<string, StudentVisitState>;
  setVisitState: Dispatch<SetStateAction<Record<string, StudentVisitState>>>;
  disabled?: boolean;
};

export const StudentVisitPicker = memo(
  ({
    students,
    visitState,
    setVisitState,
    disabled = false
  }: Readonly<Props>) => {
    const { t } = useTranslation();

    const [selectedStudentId, setSelectedStudentId] = useState<string | null>(
      null
    );

    const currentSelectedType = useMemo(() => {
      if (!selectedStudentId) {
        return null;
      }

      return visitState[selectedStudentId]?.type ?? 'UNMARKED';
    }, [selectedStudentId, visitState]);

    const isAnySelected = useMemo(
      () =>
        Object.values(visitState).some(
          s => s.status !== 'UNMARKED' && s.status !== 'ABSENT'
        ),
      [visitState]
    );

    const selectAll = useCallback(() => {
      setVisitState(prev =>
        Object.fromEntries(
          students.map(student => {
            const currentType = prev[student.id]?.type;
            const nextType =
              currentType === 'UNMARKED' ? 'REGULAR' : currentType;
            return [student.id, { status: 'PRESENT', type: nextType }];
          })
        )
      );
    }, [setVisitState, students]);

    const unselectAll = useCallback(() => {
      setVisitState(prev =>
        Object.fromEntries(
          students.map(student => {
            const currentType = prev[student.id]?.type;
            const nextType =
              currentType === 'UNMARKED' ? 'REGULAR' : currentType;
            return [student.id, { status: 'ABSENT', type: nextType }];
          })
        )
      );
    }, [setVisitState, students]);

    const togglePresence = useCallback(
      (studentId: string) => {
        if (disabled) {
          return;
        }

        setVisitState(prev => {
          const current = prev[studentId] || {
            status: 'UNMARKED',
            type: 'UNMARKED'
          };

          const isPresent = current.status === 'PRESENT';

          const nextStatus: VisitStatus = isPresent ? 'ABSENT' : 'PRESENT';

          const nextType: VisitType =
            !isPresent && current.type === 'UNMARKED'
              ? 'REGULAR'
              : current.type;

          return {
            ...prev,
            [studentId]: { status: nextStatus, type: nextType }
          };
        });
      },
      [disabled, setVisitState]
    );

    const changeVisitType = useCallback(
      (type: VisitType) => {
        if (!selectedStudentId) {
          return;
        }

        setVisitState(prev => ({
          ...prev,
          [selectedStudentId]: {
            status: type === 'UNMARKED' ? 'UNMARKED' : 'PRESENT',
            type
          }
        }));

        setSelectedStudentId(null);
      },
      [selectedStudentId, setVisitState]
    );

    const selectedStudentName = useMemo(
      () => students.find(s => s.id === selectedStudentId)?.fullName ?? '',
      [selectedStudentId, students]
    );

    useEffect(() => {
      setVisitState(prev => {
        if (Object.keys(prev).length === 0 && students.length > 0) {
          return Object.fromEntries(
            students.map(s => [s.id, { status: 'UNMARKED', type: 'UNMARKED' }])
          );
        }

        return prev;
      });
    }, [students, setVisitState]);

    return (
      <>
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
              onPress={isAnySelected ? unselectAll : selectAll}
              disabled={disabled}
            >
              {isAnySelected ? t('unselectAll') : t('selectAll')}
            </Button>
          </View>

          {students.map(student => {
            const state = visitState[student.id] ?? {
              status: 'UNMARKED',
              type: 'UNMARKED'
            };

            return (
              <Pressable
                key={student.id}
                onPress={() => setSelectedStudentId(student.id)}
                disabled={disabled}
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  height: 52
                }}
              >
                <Text
                  variant='bodyLarge'
                  style={[
                    { flex: 1, fontSize: 16, marginRight: 16 },
                    state.status === 'UNMARKED' && {
                      opacity: 0.5,
                      textDecorationLine: 'line-through'
                    },
                    state.type === 'FREE' && {
                      color: '#FFD700'
                    }
                  ]}
                >
                  {student.fullName}
                </Text>

                <Checkbox.Android
                  status={getCheckboxStatus(state.status)}
                  disabled={disabled || state.status === 'UNMARKED'}
                  onPress={() => togglePresence(student.id)}
                  color={state.type === 'FREE' ? '#FFD700' : undefined}
                />
              </Pressable>
            );
          })}
        </View>

        <CustomBottomSheet
          visible={Boolean(selectedStudentId)}
          onDismiss={() => setSelectedStudentId(null)}
        >
          <Text
            variant='titleLarge'
            style={{ marginBottom: 8 }}
          >
            {selectedStudentName}
          </Text>

          <RadioButton.Group
            onValueChange={value => changeVisitType(value as VisitType)}
            value={currentSelectedType ?? 'UNMARKED'}
          >
            {VISIT_OPTIONS.map(option => (
              <RadioButton.Item
                key={option.value}
                mode='android'
                label={t(option.label)}
                value={option.value}
                status={
                  currentSelectedType === option.value ? 'checked' : 'unchecked'
                }
              />
            ))}
          </RadioButton.Group>
        </CustomBottomSheet>
      </>
    );
  }
);
