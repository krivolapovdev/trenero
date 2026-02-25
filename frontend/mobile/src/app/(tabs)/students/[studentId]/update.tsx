import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { updateStudent } from '@/src/api/services/student/studentService';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';
import { extractErrorMessage } from '@/src/helpers/apiError';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { StudentDetails } from '@/src/types/student';

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

  const removeStudent = useStudentsStore(state => state.removeStudent);
  const allGroups = useGroupsStore(state => state.allGroups);
  const updateGroup = useGroupsStore(state => state.updateGroup);
  const student = useStudentsStore(
    state => state.allStudents[studentId]
  ) as StudentDetails;

  const {
    execute: executeUpdateStudent,
    loading: isUpdatingStudent,
    error
  } = useAsyncCallback((body: UpdateStudentRequest) =>
    updateStudent(studentId, body)
  );

  const handleSubmit = async (values: StudentFormValues) => {
    if (!student || isUpdatingStudent) {
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

    const updatedStudent = await executeUpdateStudent(request);

    removeStudent(studentId);

    const oldGroupId = student.studentGroup?.id;
    const currentGroupId = 'groupId' in request ? request.groupId : oldGroupId;

    if (oldGroupId && oldGroupId !== currentGroupId) {
      const oldGroup = allGroups[oldGroupId];

      if (oldGroup) {
        updateGroup(oldGroupId, {
          groupStudents: oldGroup.groupStudents.filter(s => s.id !== studentId)
        });
      }
    }

    if (currentGroupId) {
      const targetGroup = allGroups[currentGroupId];

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
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
    }
  }, [error, t]);

  return (
    <StudentForm
      title={t('editStudent')}
      initialData={{
        student,
        allGroups
      }}
      mutationLoading={isUpdatingStudent}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
