import type { BigDecimal, GqlDate, GqlDateTime, UUID } from './types';

export type SocialLoginInput = {
  idToken: string;
};

export type RefreshTokenInput = {
  refreshToken: string;
};

export type CreateStudentInput = {
  fullName: string;
  birthDate?: GqlDate | null;
  phone?: string | null;
  note?: string | null;
  groupId?: UUID | null;
};

export type CreateGroupInput = {
  name: string;
  defaultPrice?: BigDecimal | null;
};

export type CreateLessonInput = {
  groupId: UUID;
  startDateTime: GqlDateTime;
};

export type CreateAttendanceInput = {
  lessonId: UUID;
  studentId: UUID;
  present: boolean;
};

export type CreatePaymentInput = {
  studentId: UUID;
  amount: BigDecimal;
};
