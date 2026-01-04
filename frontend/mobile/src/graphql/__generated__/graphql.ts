/* eslint-disable */
import {TypedDocumentNode as DocumentNode} from '@graphql-typed-document-node/core';

export type Maybe<T> = T | null;
export type InputMaybe<T> = T | null | undefined;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends {
  [key: string]: unknown
}, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> =
    T
    | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  /** An arbitrary precision signed decimal */
  BigDecimal: { input: string; output: string; }
  /** An RFC-3339 compliant Full Date Scalar */
  Date: { input: string; output: string; }
  /** A slightly refined version of RFC-3339 compliant DateTime Scalar */
  DateTime: { input: string; output: string; }
  /** A universally unique identifier compliant UUID Scalar */
  UUID: { input: string; output: string; }
};

export type Attendance = {
  __typename?: 'Attendance';
  createdAt: Scalars['DateTime']['output'];
  deleted: Scalars['Boolean']['output'];
  id: Scalars['UUID']['output'];
  lessonId: Scalars['UUID']['output'];
  present: Scalars['Boolean']['output'];
  studentId: Scalars['UUID']['output'];
};

export type CreateAttendanceInput = {
  lessonId: Scalars['UUID']['input'];
  present: Scalars['Boolean']['input'];
  studentId: Scalars['UUID']['input'];
};

export type CreateGroupInput = {
  defaultPrice?: InputMaybe<Scalars['BigDecimal']['input']>;
  name: Scalars['String']['input'];
  studentIds?: InputMaybe<Array<Scalars['UUID']['input']>>;
};

export type CreateLessonInput = {
  groupId: Scalars['UUID']['input'];
  startDateTime: Scalars['DateTime']['input'];
};

export type CreatePaymentInput = {
  amount: Scalars['BigDecimal']['input'];
  studentId: Scalars['UUID']['input'];
};

export type CreateStudentInput = {
  birthDate?: InputMaybe<Scalars['Date']['input']>;
  fullName: Scalars['String']['input'];
  groupId?: InputMaybe<Scalars['UUID']['input']>;
  note?: InputMaybe<Scalars['String']['input']>;
  phone?: InputMaybe<Scalars['String']['input']>;
};

export type Group = {
  __typename?: 'Group';
  createdAt: Scalars['DateTime']['output'];
  defaultPrice?: Maybe<Scalars['BigDecimal']['output']>;
  deleted: Scalars['Boolean']['output'];
  id: Scalars['UUID']['output'];
  lessons: Array<Lesson>;
  name: Scalars['String']['output'];
  students: Array<Student>;
};

export type JwtTokens = {
  __typename?: 'JwtTokens';
  accessToken: Scalars['String']['output'];
  refreshToken: Scalars['String']['output'];
};

export type Lesson = {
  __typename?: 'Lesson';
  attendances: Array<Attendance>;
  createdAt: Scalars['DateTime']['output'];
  deleted: Scalars['Boolean']['output'];
  groupId: Scalars['UUID']['output'];
  id: Scalars['UUID']['output'];
  startDateTime: Scalars['DateTime']['output'];
};

export type LoginPayload = {
  __typename?: 'LoginPayload';
  jwtTokens: JwtTokens;
  user: User;
};

export type Mutation = {
  __typename?: 'Mutation';
  appleLogin: LoginPayload;
  createAttendance: Attendance;
  createGroup: Group;
  createLesson: Lesson;
  createPayment: Payment;
  createStudent: Student;
  deleteAttendance?: Maybe<Attendance>;
  deleteGroup?: Maybe<Group>;
  deleteLesson?: Maybe<Lesson>;
  deletePayment?: Maybe<Payment>;
  deleteStudent?: Maybe<Student>;
  googleLogin: LoginPayload;
  refreshTokens: JwtTokens;
};


export type MutationAppleLoginArgs = {
  input: SocialLoginInput;
};


export type MutationCreateAttendanceArgs = {
  input: CreateAttendanceInput;
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


export type MutationDeleteAttendanceArgs = {
  id: Scalars['UUID']['input'];
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


export type MutationGoogleLoginArgs = {
  input: SocialLoginInput;
};


export type MutationRefreshTokensArgs = {
  input: RefreshTokenInput;
};

export type Payment = {
  __typename?: 'Payment';
  amount: Scalars['BigDecimal']['output'];
  createdAt: Scalars['DateTime']['output'];
  deleted: Scalars['Boolean']['output'];
  id: Scalars['UUID']['output'];
  studentId: Scalars['UUID']['output'];
};

export type Query = {
  __typename?: 'Query';
  attendance?: Maybe<Attendance>;
  attendances: Array<Attendance>;
  group?: Maybe<Group>;
  groups: Array<Group>;
  lesson?: Maybe<Lesson>;
  lessons: Array<Lesson>;
  payment?: Maybe<Payment>;
  payments: Array<Payment>;
  student?: Maybe<Student>;
  students: Array<Student>;
};


export type QueryAttendanceArgs = {
  id: Scalars['UUID']['input'];
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

export type RefreshTokenInput = {
  refreshToken: Scalars['String']['input'];
};

export type SocialLoginInput = {
  idToken: Scalars['String']['input'];
};

export type Student = {
  __typename?: 'Student';
  attendances: Array<Attendance>;
  birthDate?: Maybe<Scalars['Date']['output']>;
  createdAt: Scalars['DateTime']['output'];
  deleted: Scalars['Boolean']['output'];
  fullName: Scalars['String']['output'];
  group?: Maybe<Group>;
  id: Scalars['UUID']['output'];
  lastAttendance?: Maybe<Attendance>;
  note?: Maybe<Scalars['String']['output']>;
  payments: Array<Payment>;
  phone?: Maybe<Scalars['String']['output']>;
};

export type User = {
  __typename?: 'User';
  email: Scalars['String']['output'];
  id: Scalars['UUID']['output'];
};

export type GetGroupQueryVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type GetGroupQuery = {
  __typename?: 'Query',
  group?: {
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: string | null,
    students: Array<{ __typename?: 'Student', id: string, fullName: string }>,
    lessons: Array<{ __typename?: 'Lesson', id: string, startDateTime: string }>
  } | null
};

export type DeleteGroupMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type DeleteGroupMutation = {
  __typename?: 'Mutation',
  deleteGroup?: { __typename?: 'Group', id: string } | null
};

export type CreateGroupMutationVariables = Exact<{
  input: CreateGroupInput;
}>;


export type CreateGroupMutation = {
  __typename?: 'Mutation',
  createGroup: {
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: string | null,
    students: Array<{ __typename?: 'Student', id: string, fullName: string }>
  }
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
    birthDate?: string | null,
    note?: string | null,
    group?: { __typename?: 'Group', id: string, name: string, defaultPrice?: string | null } | null,
    lastAttendance?: { __typename?: 'Attendance', present: boolean } | null,
    attendances: Array<{
      __typename?: 'Attendance',
      id: string,
      present: boolean,
      createdAt: string
    }>,
    payments: Array<{ __typename?: 'Payment', id: string, amount: string, createdAt: string }>
  } | null
};

export type DeleteStudentMutationVariables = Exact<{
  id: Scalars['UUID']['input'];
}>;


export type DeleteStudentMutation = {
  __typename?: 'Mutation',
  deleteStudent?: { __typename?: 'Student', id: string } | null
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
    group?: { __typename?: 'Group', id: string, name: string } | null,
    lastAttendance?: { __typename?: 'Attendance', present: boolean } | null
  }
};

export type CreatePaymentMutationVariables = Exact<{
  input: CreatePaymentInput;
}>;


export type CreatePaymentMutation = {
  __typename?: 'Mutation',
  createPayment: { __typename?: 'Payment', id: string, amount: string, createdAt: string }
};

export type GroupFieldsFragment = {
  __typename?: 'Group',
  id: string,
  name: string,
  defaultPrice?: string | null,
  students: Array<{ __typename?: 'Student', id: string, fullName: string }>
};

export type StudentFieldsFragment = {
  __typename?: 'Student',
  id: string,
  fullName: string,
  group?: { __typename?: 'Group', id: string, name: string } | null,
  lastAttendance?: { __typename?: 'Attendance', present: boolean } | null
};

export type RefreshTokensMutationVariables = Exact<{
  input: RefreshTokenInput;
}>;


export type RefreshTokensMutation = {
  __typename?: 'Mutation',
  refreshTokens: { __typename?: 'JwtTokens', accessToken: string, refreshToken: string }
};

export type GetGroupsQueryVariables = Exact<{ [key: string]: never; }>;


export type GetGroupsQuery = {
  __typename?: 'Query',
  groups: Array<{
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: string | null,
    students: Array<{ __typename?: 'Student', id: string, fullName: string }>
  }>
};

export type GetStudentsQueryVariables = Exact<{ [key: string]: never; }>;


export type GetStudentsQuery = {
  __typename?: 'Query',
  students: Array<{
    __typename?: 'Student',
    id: string,
    fullName: string,
    group?: { __typename?: 'Group', id: string, name: string } | null,
    lastAttendance?: { __typename?: 'Attendance', present: boolean } | null
  }>
};

export type GoogleLoginMutationVariables = Exact<{
  input: SocialLoginInput;
}>;


export type GoogleLoginMutation = {
  __typename?: 'Mutation',
  googleLogin: {
    __typename?: 'LoginPayload',
    user: { __typename?: 'User', id: string, email: string },
    jwtTokens: { __typename?: 'JwtTokens', accessToken: string, refreshToken: string }
  }
};

export type GetInitialDataQueryVariables = Exact<{ [key: string]: never; }>;


export type GetInitialDataQuery = {
  __typename?: 'Query',
  groups: Array<{
    __typename?: 'Group',
    id: string,
    name: string,
    defaultPrice?: string | null,
    students: Array<{ __typename?: 'Student', id: string, fullName: string }>
  }>,
  students: Array<{
    __typename?: 'Student',
    id: string,
    fullName: string,
    group?: { __typename?: 'Group', id: string, name: string } | null,
    lastAttendance?: { __typename?: 'Attendance', present: boolean } | null
  }>
};

export const GroupFieldsFragmentDoc = {
  "kind": "Document",
  "definitions": [{
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "fullName"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GroupFieldsFragment, unknown>;
export const StudentFieldsFragmentDoc = {
  "kind": "Document",
  "definitions": [{
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "name"}}]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lastAttendance"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "present"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<StudentFieldsFragment, unknown>;
export const GetGroupDocument = {
  "kind": "Document", "definitions": [{
    "kind": "OperationDefinition",
    "operation": "query",
    "name": {"kind": "Name", "value": "GetGroup"},
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
        "name": {"kind": "Name", "value": "group"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "id"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "id"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "name"}}, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "defaultPrice"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "students"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "Field",
                "name": {"kind": "Name", "value": "id"}
              }, {"kind": "Field", "name": {"kind": "Name", "value": "fullName"}}]
            }
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lessons"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "Field",
                "name": {"kind": "Name", "value": "id"}
              }, {"kind": "Field", "name": {"kind": "Name", "value": "startDateTime"}}]
            }
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetGroupQuery, GetGroupQueryVariables>;
export const DeleteGroupDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "DeleteGroup"},
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
        "name": {"kind": "Name", "value": "deleteGroup"},
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
} as unknown as DocumentNode<DeleteGroupMutation, DeleteGroupMutationVariables>;
export const CreateGroupDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "CreateGroup"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "CreateGroupInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "createGroup"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "fullName"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<CreateGroupMutation, CreateGroupMutationVariables>;
export const GetStudentDocument = {
  "kind": "Document", "definitions": [{
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
      "kind": "SelectionSet", "selections": [{
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
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "fullName"}}, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "phone"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "birthDate"}}, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "note"}
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "group"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "Field",
                "name": {"kind": "Name", "value": "id"}
              }, {"kind": "Field", "name": {"kind": "Name", "value": "name"}}, {
                "kind": "Field",
                "name": {"kind": "Name", "value": "defaultPrice"}
              }]
            }
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "lastAttendance"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "present"}}]
            }
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "attendances"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "Field",
                "name": {"kind": "Name", "value": "id"}
              }, {"kind": "Field", "name": {"kind": "Name", "value": "present"}}, {
                "kind": "Field",
                "name": {"kind": "Name", "value": "createdAt"}
              }]
            }
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "payments"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "Field",
                "name": {"kind": "Name", "value": "id"}
              }, {"kind": "Field", "name": {"kind": "Name", "value": "amount"}}, {
                "kind": "Field",
                "name": {"kind": "Name", "value": "createdAt"}
              }]
            }
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetStudentQuery, GetStudentQueryVariables>;
export const DeleteStudentDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "DeleteStudent"},
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
        "name": {"kind": "Name", "value": "deleteStudent"},
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
} as unknown as DocumentNode<DeleteStudentMutation, DeleteStudentMutationVariables>;
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
            "name": {"kind": "Name", "value": "StudentFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "name"}}]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lastAttendance"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "present"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<CreateStudentMutation, CreateStudentMutationVariables>;
export const CreatePaymentDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "CreatePayment"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "CreatePaymentInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "createPayment"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "amount"}}, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "createdAt"}
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<CreatePaymentMutation, CreatePaymentMutationVariables>;
export const RefreshTokensDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "RefreshTokens"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "RefreshTokenInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "refreshTokens"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "accessToken"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "refreshToken"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<RefreshTokensMutation, RefreshTokensMutationVariables>;
export const GetGroupsDocument = {
  "kind": "Document",
  "definitions": [{
    "kind": "OperationDefinition",
    "operation": "query",
    "name": {"kind": "Name", "value": "GetGroups"},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "groups"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "GroupFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "fullName"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetGroupsQuery, GetGroupsQueryVariables>;
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
            "name": {"kind": "Name", "value": "StudentFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "name"}}]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lastAttendance"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "present"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetStudentsQuery, GetStudentsQueryVariables>;
export const GoogleLoginDocument = {
  "kind": "Document", "definitions": [{
    "kind": "OperationDefinition",
    "operation": "mutation",
    "name": {"kind": "Name", "value": "GoogleLogin"},
    "variableDefinitions": [{
      "kind": "VariableDefinition",
      "variable": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}},
      "type": {
        "kind": "NonNullType",
        "type": {"kind": "NamedType", "name": {"kind": "Name", "value": "SocialLoginInput"}}
      }
    }],
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{
        "kind": "Field",
        "name": {"kind": "Name", "value": "googleLogin"},
        "arguments": [{
          "kind": "Argument",
          "name": {"kind": "Name", "value": "input"},
          "value": {"kind": "Variable", "name": {"kind": "Name", "value": "input"}}
        }],
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "user"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "Field",
                "name": {"kind": "Name", "value": "id"}
              }, {"kind": "Field", "name": {"kind": "Name", "value": "email"}}]
            }
          }, {
            "kind": "Field",
            "name": {"kind": "Name", "value": "jwtTokens"},
            "selectionSet": {
              "kind": "SelectionSet",
              "selections": [{
                "kind": "Field",
                "name": {"kind": "Name", "value": "accessToken"}
              }, {"kind": "Field", "name": {"kind": "Name", "value": "refreshToken"}}]
            }
          }]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GoogleLoginMutation, GoogleLoginMutationVariables>;
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
            "name": {"kind": "Name", "value": "GroupFields"}
          }]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "FragmentSpread",
            "name": {"kind": "Name", "value": "StudentFields"}
          }]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "GroupFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Group"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "name"}
      }, {"kind": "Field", "name": {"kind": "Name", "value": "defaultPrice"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "students"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "fullName"}}]
        }
      }]
    }
  }, {
    "kind": "FragmentDefinition",
    "name": {"kind": "Name", "value": "StudentFields"},
    "typeCondition": {"kind": "NamedType", "name": {"kind": "Name", "value": "Student"}},
    "selectionSet": {
      "kind": "SelectionSet",
      "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "id"}}, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "fullName"}
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "group"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{
            "kind": "Field",
            "name": {"kind": "Name", "value": "id"}
          }, {"kind": "Field", "name": {"kind": "Name", "value": "name"}}]
        }
      }, {
        "kind": "Field",
        "name": {"kind": "Name", "value": "lastAttendance"},
        "selectionSet": {
          "kind": "SelectionSet",
          "selections": [{"kind": "Field", "name": {"kind": "Name", "value": "present"}}]
        }
      }]
    }
  }]
} as unknown as DocumentNode<GetInitialDataQuery, GetInitialDataQueryVariables>;
