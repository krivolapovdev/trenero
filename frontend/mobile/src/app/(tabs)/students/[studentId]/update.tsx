import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { api } from '@/src/api';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';
import { useCustomAsyncCallback } from '@/src/hooks/useCustomAsyncCallback';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { ApiError } from '@/src/types/error';

type UpdateStudentRequest = {
  fullName?: string | null;
  phone?: string | null;
  note?: string | null;
  birthdate?: string | null;
  groupId?: string | null;
  joinedAt?: string | null;
};

export default function UpdateStudentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const recentStudents = useStudentsStore(state => state.recentStudents);
  const removeStudent = useStudentsStore(state => state.removeStudent);
  const allGroups = useGroupsStore(state => state.allGroups);
  const updateGroup = useGroupsStore(state => state.updateGroup);
  const student = recentStudents.find(s => s.id === studentId);

  const { execute: updateStudent, loading: updateStudentLoading } =
    useCustomAsyncCallback((request: UpdateStudentRequest) =>
      api.PATCH('/api/v1/students/{studentId}', {
        params: {
          path: { studentId }
        },
        body: request
      })
    );

  const handleSubmit = async (values: StudentFormValues) => {
    if (!student || updateStudentLoading) {
      return;
    }

    const request: UpdateStudentRequest = {};

    if (values.fullName !== student.fullName) {
      request.fullName = values.fullName ?? null;
    }

    if (values.phone !== student.phone) {
      request.phone = values.phone ?? null;
    }

    if (values.note !== student.note) {
      request.note = values.note ?? null;
    }

    if (values.birthdate !== student.birthdate) {
      request.birthdate = values.birthdate ?? null;
    }

    if (values.groupId !== student.studentGroup?.id) {
      request.groupId = values.groupId ?? null;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    try {
      const updatedStudent = await updateStudent(request);

      removeStudent(studentId);

      const oldGroupId = student.studentGroup?.id;
      const currentGroupId =
        'groupId' in request ? request.groupId : oldGroupId;

      if (oldGroupId && oldGroupId !== currentGroupId) {
        const oldGroup = allGroups.find(g => g.id === oldGroupId);
        if (oldGroup) {
          updateGroup(oldGroupId, {
            groupStudents: oldGroup.groupStudents.filter(
              s => s.id !== studentId
            )
          });
        }
      }

      if (currentGroupId) {
        const targetGroup = allGroups.find(g => g.id === currentGroupId);
        if (targetGroup) {
          const otherStudents = targetGroup.groupStudents.filter(
            s => s.id !== studentId
          );
          updateGroup(currentGroupId, {
            groupStudents: [...otherStudents, updatedStudent]
          });
        }
      }

      router.back();
    } catch (err) {
      const errorData = err as ApiError;
      Alert.alert(t('error'), errorData.detail);
    }
  };

  return (
    <StudentForm
      title={t('editStudent')}
      initialData={{
        student,
        allGroups
      }}
      mutationLoading={updateStudentLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
