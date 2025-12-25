import type { BigDecimal, GqlDate, GqlDateTime, UUID } from './types';

export interface SocialLoginInput {
  idToken: string;
}

export interface RefreshTokenInput {
  refreshToken: string;
}

export interface CreateStudentInput {
  fullName: string;
  birthDate?: GqlDate | null;
  phone?: string | null;
  note?: string | null;
  groupId?: UUID | null;
}

export interface CreateGroupInput {
  name: string;
  defaultPrice?: BigDecimal | null;
}

export interface CreateLessonInput {
  groupId: UUID;
  startDateTime: GqlDateTime;
}

export interface CreateAttendanceInput {
  lessonId: UUID;
  studentId: UUID;
  present: boolean;
}

export interface CreatePaymentInput {
  studentId: UUID;
  amount: BigDecimal;
}
