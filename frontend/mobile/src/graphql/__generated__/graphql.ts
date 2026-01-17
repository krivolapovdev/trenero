/* eslint-disable */
import {TypedDocumentNode as DocumentNode} from '@graphql-typed-document-node/core';

export type Maybe<T> = T | null;
export type InputMaybe<T> = T | null | undefined;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  /** An arbitrary precision signed decimal */
  BigDecimal: { input: number; output: number; }
  /** An RFC-3339 compliant Full Date Scalar */
  Date: { input: string; output: string; }
  /** A slightly refined version of RFC-3339 compliant DateTime Scalar */
  DateTime: { input: string; output: string; }
  /** A universally unique identifier compliant UUID Scalar */
  UUID: { input: string; output: string; }
};

export type CreateGroupInput = {
  defaultPrice?: InputMaybe<Scalars['BigDecimal']['input']>;
  name: Scalars['String']['input'];
  note?: InputMaybe<Scalars['String']['input']>;
  studentIds: Array<Scalars['UUID']['input']>;
};

export type CreateLessonInput = {
  groupId: Scalars['UUID']['input'];
  startDateTime: Scalars['DateTime']['input'];
  students: Array<LessonStudentInput>;
};

export type CreatePaymentInput = {
  amount: Scalars['BigDecimal']['input'];
  date: Scalars['Date']['input'];
  lessonsPerPayment: Scalars['Int']['input'];
  studentId: Scalars['UUID']['input'];
};

export type CreateStudentInput = {
  birthdate?: InputMaybe<Scalars['Date']['input']>;
  fullName: Scalars['String']['input'];
  groupId?: InputMaybe<Scalars['UUID']['input']>;
  note?: InputMaybe<Scalars['String']['input']>;
  phone?: InputMaybe<Scalars['String']['input']>;
};

export type CreateVisitInput = {
  lessonId: Scalars['UUID']['input'];
  present: Scalars['Boolean']['input'];
  studentId: Scalars['UUID']['input'];
};

export type Group = {
  __typename?: 'Group';
  createdAt: Scalars['DateTime']['output'];
  defaultPrice?: Maybe<Scalars['BigDecimal']['output']>;
  id: Scalars['UUID']['output'];
  lessons: Array<Lesson>;
  name: Scalars['String']['output'];
  note?: Maybe<Scalars['String']['output']>;
  students: Array<Student>;
};

export type JwtTokens = {
  __typename?: 'JwtTokens';
  accessToken: Scalars['String']['output'];
  refreshToken: Scalars['String']['output'];
};

export type Lesson = {
  __typename?: 'Lesson';
  createdAt: Scalars['DateTime']['output'];
  group: Group;
  id: Scalars['UUID']['output'];
  startDateTime: Scalars['DateTime']['output'];
  visits: Array<Visit>;
};

export type LessonStudentInput = {
  present: Scalars['Boolean']['input'];
  studentId: Scalars['UUID']['input'];
};

export type LoginPayload = {
  __typename?: 'LoginPayload';
  jwtTokens: JwtTokens;
  user: User;
};

export type Mutation = {
  __typename?: 'Mutation';
  appleLogin: LoginPayload;
  createGroup: Group;
  createLesson: Lesson;
  createPayment: Payment;
  createStudent: Student;
  createVisit: Visit;
  deleteGroup?: Maybe<Group>;
  deleteLesson?: Maybe<Lesson>;
  deletePayment?: Maybe<Payment>;
  deleteStudent?: Maybe<Student>;
  deleteVisit?: Maybe<Visit>;
  googleLogin: LoginPayload;
  refreshTokens: JwtTokens;
  updateGroup?: Maybe<Group>;
  updateLesson?: Maybe<Lesson>;
  updatePayment?: Maybe<Payment>;
  updateStudent?: Maybe<Student>;
  updateVisit?: Maybe<Visit>;
};


export type MutationAppleLoginArgs = {
  input: SocialLoginInput;
};


export type MutationCreateGroupArgs = {
  input: CreateGroupInput;
};


export type MutationCreateLessonArgs = {
  input: CreateLessonInput;
};


export type MutationCreatePaymentArgs = {
  input: CreatePaymentInput;
};


export type MutationCreateStudentArgs = {
  input: CreateStudentInput;
};


export type MutationCreateVisitArgs = {
  input: CreateVisitInput;
};


export type MutationDeleteGroupArgs = {
  id: Scalars['UUID']['input'];
};


export type MutationDeleteLessonArgs = {
  id: Scalars['UUID']['input'];
};


export type MutationDeletePaymentArgs = {
  id: Scalars['UUID']['input'];
};


export type MutationDeleteStudentArgs = {
  id: Scalars['UUID']['input'];
};


export type MutationDeleteVisitArgs = {
  id: Scalars['UUID']['input'];
};


export type MutationGoogleLoginArgs = {
  input: SocialLoginInput;
};


export type MutationRefreshTokensArgs = {
  input: RefreshTokenInput;
};


export type MutationUpdateGroupArgs = {
  id: Scalars['UUID']['input'];
  input: UpdateGroupInput;
};


export type MutationUpdateLessonArgs = {
  id: Scalars['UUID']['input'];
  input: UpdateLessonInput;
};


export type MutationUpdatePaymentArgs = {
  id: Scalars['UUID']['input'];
  input: UpdatePaymentInput;
};


export type MutationUpdateStudentArgs = {
  id: Scalars['UUID']['input'];
  input: UpdateStudentInput;
};


export type MutationUpdateVisitArgs = {
  id: Scalars['UUID']['input'];
  input: UpdateVisitInput;
};

export type Payment = {
  __typename?: 'Payment';
  amount: Scalars['BigDecimal']['output'];
  createdAt: Scalars['DateTime']['output'];
  date: Scalars['Date']['output'];
  id: Scalars['UUID']['output'];
  lessonsPerPayment: Scalars['Int']['output'];
  student: Student;
};

export type Query = {
  __typename?: 'Query';
  group?: Maybe<Group>;
  groups: Array<Group>;
  lesson?: Maybe<Lesson>;
  lessons: Array<Lesson>;
  payment?: Maybe<Payment>;
  payments: Array<Payment>;
  student?: Maybe<Student>;
  students: Array<Student>;
  visit?: Maybe<Visit>;
  visits: Array<Visit>;
};


export type QueryGroupArgs = {
  id: Scalars['UUID']['input'];
};


export type QueryLessonArgs = {
  id: Scalars['UUID']['input'];
};


export type QueryPaymentArgs = {
  id: Scalars['UUID']['input'];
};


export type QueryStudentArgs = {
  id: Scalars['UUID']['input'];
};


export type QueryVisitArgs = {
  id: Scalars['UUID']['input'];
};

export type RefreshTokenInput = {
  refreshToken: Scalars['String']['input'];
};

export type SocialLoginInput = {
  idToken: Scalars['String']['input'];
};

export type Student = {
  __typename?: 'Student';
  birthdate?: Maybe<Scalars['Date']['output']>;
  createdAt: Scalars['DateTime']['output'];
  fullName: Scalars['String']['output'];
  group?: Maybe<Group>;
  id: Scalars['UUID']['output'];
  note?: Maybe<Scalars['String']['output']>;
  payments: Array<Payment>;
  phone?: Maybe<Scalars['String']['output']>;
  visits: Array<Visit>;
};

export type UpdateGroupInput = {
  defaultPrice?: InputMaybe<Scalars['BigDecimal']['input']>;
  name?: InputMaybe<Scalars['String']['input']>;
  note?: InputMaybe<Scalars['String']['input']>;
  studentIds?: InputMaybe<Array<Scalars['UUID']['input']>>;
};

export type UpdateLessonInput = {
  startDateTime?: InputMaybe<Scalars['DateTime']['input']>;
  students?: InputMaybe<Array<LessonStudentInput>>;
};

export type UpdatePaymentInput = {
  amount?: InputMaybe<Scalars['BigDecimal']['input']>;
  date?: InputMaybe<Scalars['Date']['input']>;
  lessonsPerPayment?: InputMaybe<Scalars['Int']['input']>;
};

export type UpdateStudentInput = {
  birthdate?: InputMaybe<Scalars['Date']['input']>;
  fullName?: InputMaybe<Scalars['String']['input']>;
  groupId?: InputMaybe<Scalars['UUID']['input']>;
  note?: InputMaybe<Scalars['String']['input']>;
  phone?: InputMaybe<Scalars['String']['input']>;
};

export type UpdateVisitInput = {
  present?: InputMaybe<Scalars['Boolean']['input']>;
};

export type User = {
  __typename?: 'User';
  email: Scalars['String']['output'];
  id: Scalars['UUID']['output'];
};

export type Visit = {
  __typename?: 'Visit';
  createdAt: Scalars['DateTime']['output'];
  id: Scalars['UUID']['output'];
  lesson: Lesson;
  present: Scalars['Boolean']['output'];
  student: Student;
};

export type DeleteGroupMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type DeleteGroupMutation = { __typename?: 'Mutation', deleteGroup?: { __typename?: 'Group', id: string } | null };

export type DeleteLessonMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type DeleteLessonMutation = {
  __typename?: 'Mutation',
  deleteLesson?: { __typename?: 'Lesson', id: string } | null
};

export type UpdateLessonMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
  input: UpdateLessonInput;
}>;


export type UpdateLessonMutation = {
  __typename?: 'Mutation',
  updateLesson?: {
    __typename?: 'Lesson',
    id: string,
    startDateTime: string,
    group: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null,
      students: Array<{
        __typename?: 'Student',
        id: string,
        fullName: string,
        phone?: string | null,
        birthdate?: string | null,
        note?: string | null
      }>
    },
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      student: {
        __typename?: 'Student',
        id: string,
        fullName: string,
        phone?: string | null,
        birthdate?: string | null,
        note?: string | null
      }
    }>
  } | null
};

export type CreateLessonMutationVariables = Exact<{
  input: CreateLessonInput;
}>;


export type CreateLessonMutation = {
  __typename?: 'Mutation',
  createLesson: {
    __typename?: 'Lesson',
    id: string,
    startDateTime: string,
    group: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null,
      students: Array<{
        __typename?: 'Student',
        id: string,
        fullName: string,
        phone?: string | null,
        birthdate?: string | null,
        note?: string | null
      }>
    },
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      student: {
        __typename?: 'Student',
        id: string,
        fullName: string,
        phone?: string | null,
        birthdate?: string | null,
        note?: string | null
      }
    }>
  }
};

export type UpdateGroupMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
  input: UpdateGroupInput;
}>;


export type UpdateGroupMutation = {
  __typename?: 'Mutation',
  updateGroup?: {
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: number | null,
    note?: string | null,
    students: Array<{
      __typename?: 'Student',
      id: string,
      fullName: string,
      phone?: string | null,
      birthdate?: string | null,
      note?: string | null
    }>,
    lessons: Array<{ __typename?: 'Lesson', id: string, startDateTime: string }>
  } | null
};

export type CreateGroupMutationVariables = Exact<{
  input: CreateGroupInput;
}>;


export type CreateGroupMutation = { __typename?: 'Mutation', createGroup: { __typename?: 'Group', id: string, name: string, defaultPrice?: number | null, note?: string | null, students: Array<{ __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null }>, lessons: Array<{ __typename?: 'Lesson', id: string, startDateTime: string }> } };

export type DeleteStudentMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type DeleteStudentMutation = { __typename?: 'Mutation', deleteStudent?: { __typename?: 'Student', id: string } | null };

export type UpdatePaymentMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
  input: UpdatePaymentInput;
}>;


export type UpdatePaymentMutation = {
  __typename?: 'Mutation',
  updatePayment?: {
    __typename?: 'Payment',
    id: string,
    amount: number,
    date: string,
    lessonsPerPayment: number,
    student: {
      __typename?: 'Student',
      id: string,
      fullName: string,
      phone?: string | null,
      birthdate?: string | null,
      note?: string | null
    }
  } | null
};

export type CreatePaymentMutationVariables = Exact<{
  input: CreatePaymentInput;
}>;


export type CreatePaymentMutation = { __typename?: 'Mutation', createPayment: { __typename?: 'Payment', id: string, amount: number, date: string, lessonsPerPayment: number, student: { __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null } } };

export type EditStudentMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
  input: UpdateStudentInput;
}>;


export type EditStudentMutation = {
  __typename?: 'Mutation',
  updateStudent?: {
    __typename?: 'Student',
    id: string,
    fullName: string,
    phone?: string | null,
    birthdate?: string | null,
    note?: string | null,
    group?: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null
    } | null,
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      lesson: { __typename?: 'Lesson', id: string, startDateTime: string }
    }>,
    payments: Array<{
      __typename?: 'Payment',
      id: string,
      amount: number,
      date: string,
      lessonsPerPayment: number
    }>
  } | null
};

export type CreateStudentMutationVariables = Exact<{
  input: CreateStudentInput;
}>;


export type CreateStudentMutation = {
  __typename?: 'Mutation',
  createStudent: {
    __typename?: 'Student',
    id: string,
    fullName: string,
    phone?: string | null,
    birthdate?: string | null,
    note?: string | null,
    group?: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null
    } | null,
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      lesson: { __typename?: 'Lesson', id: string, startDateTime: string }
    }>,
    payments: Array<{
      __typename?: 'Payment',
      id: string,
      amount: number,
      date: string,
      lessonsPerPayment: number
    }>
  }
};

export type DeletePaymentMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type DeletePaymentMutation = { __typename?: 'Mutation', deletePayment?: { __typename?: 'Payment', id: string } | null };

export type StudentCoreFieldsFragment = { __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null };

export type GroupCoreFieldsFragment = { __typename?: 'Group', id: string, name: string, defaultPrice?: number | null, note?: string | null };

export type LessonCoreFieldsFragment = { __typename?: 'Lesson', id: string, startDateTime: string };

export type PaymentCoreFieldsFragment = { __typename?: 'Payment', id: string, amount: number, date: string, lessonsPerPayment: number };

export type VisitCoreFieldsFragment = { __typename?: 'Visit', id: string, present: boolean };

export type PaymentDetailsFieldsFragment = { __typename?: 'Payment', id: string, amount: number, date: string, lessonsPerPayment: number, student: { __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null } };

export type GroupDetailsFieldsFragment = { __typename?: 'Group', id: string, name: string, defaultPrice?: number | null, note?: string | null, students: Array<{ __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null }>, lessons: Array<{ __typename?: 'Lesson', id: string, startDateTime: string }> };

export type StudentDetailsFieldsFragment = {
  __typename?: 'Student',
  id: string,
  fullName: string,
  phone?: string | null,
  birthdate?: string | null,
  note?: string | null,
  group?: {
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: number | null,
    note?: string | null
  } | null,
  visits: Array<{
    __typename?: 'Visit',
    id: string,
    present: boolean,
    lesson: { __typename?: 'Lesson', id: string, startDateTime: string }
  }>,
  payments: Array<{
    __typename?: 'Payment',
    id: string,
    amount: number,
    date: string,
    lessonsPerPayment: number
  }>
};

export type LessonDetailsFieldsFragment = {
  __typename?: 'Lesson',
  id: string,
  startDateTime: string,
  group: {
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: number | null,
    note?: string | null,
    students: Array<{
      __typename?: 'Student',
      id: string,
      fullName: string,
      phone?: string | null,
      birthdate?: string | null,
      note?: string | null
    }>
  },
  visits: Array<{
    __typename?: 'Visit',
    id: string,
    present: boolean,
    student: {
      __typename?: 'Student',
      id: string,
      fullName: string,
      phone?: string | null,
      birthdate?: string | null,
      note?: string | null
    }
  }>
};

export type RefreshTokensMutationVariables = Exact<{
  input: RefreshTokenInput;
}>;


export type RefreshTokensMutation = { __typename?: 'Mutation', refreshTokens: { __typename?: 'JwtTokens', accessToken: string, refreshToken: string } };

export type GetGroupsQueryVariables = Exact<{ [key: string]: never; }>;


export type GetGroupsQuery = { __typename?: 'Query', groups: Array<{ __typename?: 'Group', id: string, name: string, defaultPrice?: number | null, note?: string | null, students: Array<{ __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null }> }> };

export type GetGroupQueryVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type GetGroupQuery = { __typename?: 'Query', group?: { __typename?: 'Group', id: string, name: string, defaultPrice?: number | null, note?: string | null, students: Array<{ __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null }>, lessons: Array<{ __typename?: 'Lesson', id: string, startDateTime: string }> } | null };

export type GetStudentsQueryVariables = Exact<{ [key: string]: never; }>;


export type GetStudentsQuery = {
  __typename?: 'Query',
  students: Array<{
    __typename?: 'Student',
    id: string,
    fullName: string,
    phone?: string | null,
    birthdate?: string | null,
    note?: string | null,
    group?: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null
    } | null,
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      lesson: { __typename?: 'Lesson', id: string, startDateTime: string }
    }>,
    payments: Array<{
      __typename?: 'Payment',
      id: string,
      amount: number,
      date: string,
      lessonsPerPayment: number
    }>
  }>
};

export type GetStudentQueryVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type GetStudentQuery = {
  __typename?: 'Query',
  student?: {
    __typename?: 'Student',
    id: string,
    fullName: string,
    phone?: string | null,
    birthdate?: string | null,
    note?: string | null,
    group?: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null
    } | null,
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      lesson: { __typename?: 'Lesson', id: string, startDateTime: string }
    }>,
    payments: Array<{
      __typename?: 'Payment',
      id: string,
      amount: number,
      date: string,
      lessonsPerPayment: number
    }>
  } | null
};

export type GetLessonQueryVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type GetLessonQuery = {
  __typename?: 'Query',
  lesson?: {
    __typename?: 'Lesson',
    id: string,
    startDateTime: string,
    group: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null,
      students: Array<{
        __typename?: 'Student',
        id: string,
        fullName: string,
        phone?: string | null,
        birthdate?: string | null,
        note?: string | null
      }>
    },
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      student: {
        __typename?: 'Student',
        id: string,
        fullName: string,
        phone?: string | null,
        birthdate?: string | null,
        note?: string | null
      }
    }>
  } | null
};

export type GetPaymentQueryVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type GetPaymentQuery = { __typename?: 'Query', payment?: { __typename?: 'Payment', id: string, amount: number, date: string, lessonsPerPayment: number, student: { __typename?: 'Student', id: string, fullName: string, phone?: string | null, birthdate?: string | null, note?: string | null } } | null };

export type GoogleLoginMutationVariables = Exact<{
  input: SocialLoginInput;
}>;


export type GoogleLoginMutation = { __typename?: 'Mutation', googleLogin: { __typename?: 'LoginPayload', user: { __typename?: 'User', id: string, email: string }, jwtTokens: { __typename?: 'JwtTokens', accessToken: string, refreshToken: string } } };

export type GetInitialDataQueryVariables = Exact<{ [key: string]: never; }>;


export type GetInitialDataQuery = {
  __typename?: 'Query',
  groups: Array<{
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: number | null,
    note?: string | null,
    students: Array<{
      __typename?: 'Student',
      id: string,
      fullName: string,
      phone?: string | null,
      birthdate?: string | null,
      note?: string | null
    }>,
    lessons: Array<{ __typename?: 'Lesson', id: string, startDateTime: string }>
  }>,
  students: Array<{
    __typename?: 'Student',
    id: string,
    fullName: string,
    phone?: string | null,
    birthdate?: string | null,
    note?: string | null,
    group?: {
      __typename?: 'Group',
      id: string,
      name: string,
      defaultPrice?: number | null,
      note?: string | null
    } | null,
    visits: Array<{
      __typename?: 'Visit',
      id: string,
      present: boolean,
      lesson: { __typename?: 'Lesson', id: string, startDateTime: string }
    }>,
    payments: Array<{
      __typename?: 'Payment',
      id: string,
      amount: number,
      date: string,
      lessonsPerPayment: number
    }>
  }>
};

export const PaymentCoreFieldsFragmentDoc = {"kind":"Document","definitions":[{"kind":"FragmentDefinition","name":{"kind":"Name","value":"PaymentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Payment"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"amount"}},{"kind":"Field","name":{"kind":"Name","value":"date"}},{"kind":"Field","name":{"kind":"Name","value":"lessonsPerPayment"}}]}}]} as unknown as DocumentNode<PaymentCoreFieldsFragment, unknown>;
export const StudentCoreFieldsFragmentDoc = {"kind":"Document","definitions":[{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}}]} as unknown as DocumentNode<StudentCoreFieldsFragment, unknown>;
export const PaymentDetailsFieldsFragmentDoc = {"kind":"Document","definitions":[{"kind":"FragmentDefinition","name":{"kind":"Name","value":"PaymentDetailsFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Payment"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"PaymentCoreFields"}},{"kind":"Field","name":{"kind":"Name","value":"student"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"StudentCoreFields"}}]}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"PaymentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Payment"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"amount"}},{"kind":"Field","name":{"kind":"Name","value":"date"}},{"kind":"Field","name":{"kind":"Name","value":"lessonsPerPayment"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}}]} as unknown as DocumentNode<PaymentDetailsFieldsFragment, unknown>;
export const GroupCoreFieldsFragmentDoc = {"kind":"Document","definitions":[{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"name"}},{"kind":"Field","name":{"kind":"Name","value":"defaultPrice"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}}]} as unknown as DocumentNode<GroupCoreFieldsFragment, unknown>;
export const LessonCoreFieldsFragmentDoc = {"kind":"Document","definitions":[{"kind":"FragmentDefinition","name":{"kind":"Name","value":"LessonCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Lesson"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"startDateTime"}}]}}]} as unknown as DocumentNode<LessonCoreFieldsFragment, unknown>;
export const GroupDetailsFieldsFragmentDoc = {"kind":"Document","definitions":[{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupDetailsFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"GroupCoreFields"}},{"kind":"Field","name":{"kind":"Name","value":"students"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"StudentCoreFields"}}]}},{"kind":"Field","name":{"kind":"Name","value":"lessons"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"LessonCoreFields"}}]}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"name"}},{"kind":"Field","name":{"kind":"Name","value":"defaultPrice"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"LessonCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Lesson"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"startDateTime"}}]}}]} as unknown as DocumentNode<GroupDetailsFieldsFragment, unknown>;
export const VisitCoreFieldsFragmentDoc = {
  "kind": "Document",
  "definitions": [{
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }]
} as unknown as DocumentNode<VisitCoreFieldsFragment, unknown>;
export const StudentDetailsFieldsFragmentDoc = {
  "kind": "Document", "definitions": [{
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "StudentCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lesson"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "LessonCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "payments"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "PaymentCoreFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "amount"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "date"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessonsPerPayment"}
      }]
    }
  }]
} as unknown as DocumentNode<StudentDetailsFieldsFragment, unknown>;
export const LessonDetailsFieldsFragmentDoc = {
  "kind": "Document", "definitions": [{
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "LessonCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "students"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "student"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }]
} as unknown as DocumentNode<LessonDetailsFieldsFragment, unknown>;
export const DeleteGroupDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"DeleteGroup"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"id"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"UUID"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"deleteGroup"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"id"},"value":{"kind":"Variable","name":{"kind":"Name","value":"id"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}}]}}]}}]} as unknown as DocumentNode<DeleteGroupMutation, DeleteGroupMutationVariables>;
export const DeleteLessonDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "DeleteLesson"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UUID"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "deleteLesson"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<DeleteLessonMutation, DeleteLessonMutationVariables>;
export const UpdateLessonDocument = {
  "kind": "Document", "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "UpdateLesson"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UUID"}}
      }
    }, {
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UpdateLessonInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "updateLesson"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }, {
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "LessonDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "LessonCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "students"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "student"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<UpdateLessonMutation, UpdateLessonMutationVariables>;
export const CreateLessonDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "CreateLesson"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "CreateLessonInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "createLesson"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "LessonDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "LessonCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "students"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "student"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<CreateLessonMutation, CreateLessonMutationVariables>;
export const UpdateGroupDocument = {
  "kind": "Document", "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "UpdateGroup"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UUID"}}
      }
    }, {
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UpdateGroupInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "updateGroup"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }, {
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "GroupCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessons"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "LessonCoreFields"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<UpdateGroupMutation, UpdateGroupMutationVariables>;
export const CreateGroupDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"CreateGroup"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"input"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"CreateGroupInput"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"createGroup"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"input"},"value":{"kind":"Variable","name":{"kind":"Name","value":"input"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"GroupDetailsFields"}}]}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"name"}},{"kind":"Field","name":{"kind":"Name","value":"defaultPrice"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"LessonCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Lesson"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"startDateTime"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupDetailsFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"GroupCoreFields"}},{"kind":"Field","name":{"kind":"Name","value":"students"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"StudentCoreFields"}}]}},{"kind":"Field","name":{"kind":"Name","value":"lessons"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"LessonCoreFields"}}]}}]}}]} as unknown as DocumentNode<CreateGroupMutation, CreateGroupMutationVariables>;
export const DeleteStudentDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"DeleteStudent"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"id"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"UUID"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"deleteStudent"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"id"},"value":{"kind":"Variable","name":{"kind":"Name","value":"id"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}}]}}]}}]} as unknown as DocumentNode<DeleteStudentMutation, DeleteStudentMutationVariables>;
export const UpdatePaymentDocument = {
  "kind": "Document", "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "UpdatePayment"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UUID"}}
      }
    }, {
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UpdatePaymentInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "updatePayment"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }, {
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "PaymentDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "amount"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "date"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessonsPerPayment"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "PaymentCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "student"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentCoreFields"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<UpdatePaymentMutation, UpdatePaymentMutationVariables>;
export const CreatePaymentDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"CreatePayment"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"input"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"CreatePaymentInput"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"createPayment"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"input"},"value":{"kind":"Variable","name":{"kind":"Name","value":"input"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"PaymentDetailsFields"}}]}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"PaymentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Payment"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"amount"}},{"kind":"Field","name":{"kind":"Name","value":"date"}},{"kind":"Field","name":{"kind":"Name","value":"lessonsPerPayment"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"PaymentDetailsFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Payment"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"PaymentCoreFields"}},{"kind":"Field","name":{"kind":"Name","value":"student"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"StudentCoreFields"}}]}}]}}]} as unknown as DocumentNode<CreatePaymentMutation, CreatePaymentMutationVariables>;
export const EditStudentDocument = {
  "kind": "Document", "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "EditStudent"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UUID"}}
      }
    }, {
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UpdateStudentInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "updateStudent"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }, {
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "amount"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "date"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessonsPerPayment"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "StudentCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lesson"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "LessonCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "payments"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "PaymentCoreFields"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<EditStudentMutation, EditStudentMutationVariables>;
export const CreateStudentDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "CreateStudent"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "CreateStudentInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "createStudent"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "amount"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "date"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessonsPerPayment"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "StudentCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lesson"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "LessonCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "payments"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "PaymentCoreFields"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<CreateStudentMutation, CreateStudentMutationVariables>;
export const DeletePaymentDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"DeletePayment"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"id"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"UUID"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"deletePayment"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"id"},"value":{"kind":"Variable","name":{"kind":"Name","value":"id"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}}]}}]}}]} as unknown as DocumentNode<DeletePaymentMutation, DeletePaymentMutationVariables>;
export const RefreshTokensDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"RefreshTokens"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"input"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"RefreshTokenInput"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"refreshTokens"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"input"},"value":{"kind":"Variable","name":{"kind":"Name","value":"input"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"accessToken"}},{"kind":"Field","name":{"kind":"Name","value":"refreshToken"}}]}}]}}]} as unknown as DocumentNode<RefreshTokensMutation, RefreshTokensMutationVariables>;
export const GetGroupsDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"GetGroups"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"groups"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"GroupCoreFields"}},{"kind":"Field","name":{"kind":"Name","value":"students"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"StudentCoreFields"}}]}}]}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"name"}},{"kind":"Field","name":{"kind":"Name","value":"defaultPrice"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}}]} as unknown as DocumentNode<GetGroupsQuery, GetGroupsQueryVariables>;
export const GetGroupDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"GetGroup"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"id"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"UUID"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"group"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"id"},"value":{"kind":"Variable","name":{"kind":"Name","value":"id"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"GroupDetailsFields"}}]}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"name"}},{"kind":"Field","name":{"kind":"Name","value":"defaultPrice"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"LessonCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Lesson"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"startDateTime"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"GroupDetailsFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Group"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"GroupCoreFields"}},{"kind":"Field","name":{"kind":"Name","value":"students"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"StudentCoreFields"}}]}},{"kind":"Field","name":{"kind":"Name","value":"lessons"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"LessonCoreFields"}}]}}]}}]} as unknown as DocumentNode<GetGroupQuery, GetGroupQueryVariables>;
export const GetStudentsDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "query",
    "name": {"kind": "Name", "value": "GetStudents"},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "amount"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "date"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessonsPerPayment"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "StudentCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lesson"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "LessonCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "payments"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "PaymentCoreFields"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetStudentsQuery, GetStudentsQueryVariables>;
export const GetStudentDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "query",
    "name": {"kind": "Name", "value": "GetStudent"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UUID"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "student"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "amount"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "date"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessonsPerPayment"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "StudentCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lesson"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "LessonCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "payments"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "PaymentCoreFields"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetStudentQuery, GetStudentQueryVariables>;
export const GetLessonDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "query",
    "name": {"kind": "Name", "value": "GetLesson"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "UUID"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "lesson"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "LessonDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "LessonCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "students"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "student"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "StudentCoreFields"}
              }]
            }
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetLessonQuery, GetLessonQueryVariables>;
export const GetPaymentDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"GetPayment"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"id"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"UUID"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"payment"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"id"},"value":{"kind":"Variable","name":{"kind":"Name","value":"id"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"PaymentDetailsFields"}}]}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"PaymentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Payment"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"amount"}},{"kind":"Field","name":{"kind":"Name","value":"date"}},{"kind":"Field","name":{"kind":"Name","value":"lessonsPerPayment"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"StudentCoreFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Student"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"fullName"}},{"kind":"Field","name":{"kind":"Name","value":"phone"}},{"kind":"Field","name":{"kind":"Name","value":"birthdate"}},{"kind":"Field","name":{"kind":"Name","value":"note"}}]}},{"kind":"FragmentDefinition","name":{"kind":"Name","value":"PaymentDetailsFields"},"typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"Payment"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"PaymentCoreFields"}},{"kind":"Field","name":{"kind":"Name","value":"student"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"FragmentSpread","name":{"kind":"Name","value":"StudentCoreFields"}}]}}]}}]} as unknown as DocumentNode<GetPaymentQuery, GetPaymentQueryVariables>;
export const GoogleLoginDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"GoogleLogin"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"input"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"SocialLoginInput"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"googleLogin"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"input"},"value":{"kind":"Variable","name":{"kind":"Name","value":"input"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"user"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"email"}}]}},{"kind":"Field","name":{"kind":"Name","value":"jwtTokens"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"accessToken"}},{"kind":"Field","name":{"kind":"Name","value":"refreshToken"}}]}}]}}]}}]} as unknown as DocumentNode<GoogleLoginMutation, GoogleLoginMutationVariables>;
export const GetInitialDataDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "query",
    "name": {"kind": "Name", "value": "GetInitialData"},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "groups"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupDetailsFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentDetailsFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "note"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "phone"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "birthdate"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "note"}}]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "LessonCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Lesson"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "startDateTime"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "VisitCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Visit"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "present"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "PaymentCoreFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Payment"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "amount"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "date"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessonsPerPayment"}
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "GroupCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lessons"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "LessonCoreFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentDetailsFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "FragmentSpread",
        "name": {"kind": "Name", "value": "StudentCoreFields"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupCoreFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "visits"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "VisitCoreFields"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lesson"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "FragmentSpread",
                "name": {"kind": "Name", "value": "LessonCoreFields"}
              }]
            }
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "payments"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "PaymentCoreFields"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetInitialDataQuery, GetInitialDataQueryVariables>;
