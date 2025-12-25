export type UUID = string;
export type GqlDateTime = string;
export type GqlDate = string;
export type BigDecimal = string;

export type JwtTokens = {
  accessToken: string;
  refreshToken: string;
};

export type User = {
  id: UUID;
  email: string;
};

export type LoginPayload = {
  user: User;
  jwtTokens: JwtTokens;
};

export type Student = {
  id: UUID;
  fullName: string;
  createdAt: GqlDateTime;
  birthDate?: GqlDate | null;
  phone?: string | null;
  note?: string | null;
  deleted: boolean;
  group?: Group | null;
  payments: Payment[];
  attendances: Attendance[];
};

export type Group = {
  id: UUID;
  name: string;
  createdAt: GqlDateTime;
  defaultPrice?: BigDecimal | null;
  deleted: boolean;
  students: Student[];
  lessons: Lesson[];
};

export type Lesson = {
  id: UUID;
  groupId: UUID;
  startDateTime: GqlDateTime;
  createdAt: GqlDateTime;
  deleted: boolean;
  attendances: Attendance[];
};

export type Attendance = {
  id: UUID;
  lessonId: UUID;
  studentId: UUID;
  present: boolean;
  createdAt: GqlDateTime;
  deleted: boolean;
};

export type Payment = {
  id: UUID;
  studentId: UUID;
  amount: BigDecimal;
  createdAt: GqlDateTime;
  deleted: boolean;
};
