/* eslint-disable */
import * as types from './graphql';
import {TypedDocumentNode as DocumentNode} from '@graphql-typed-document-node/core';

/**
 * Map of all GraphQL operations in the project.
 *
 * This map has several performance disadvantages:
 * 1. It is not tree-shakeable, so it will include all operations in the project.
 * 2. It is not minifiable, so the string of a GraphQL query will be multiple times inside the bundle.
 * 3. It does not support dead code elimination, so it will add unused operations.
 *
 * Therefore it is highly recommended to use the babel or swc plugin for production.
 * Learn more about it here: https://the-guild.dev/graphql/codegen/plugins/presets/preset-client#reducing-bundle-size
 */
type Documents = {
  "\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n": typeof types.DeleteGroupDocument,
  "\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonFields\n        }\n    }\n": typeof types.CreateLessonDocument,
  "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n": typeof types.CreateGroupDocument,
  "\n    query GetPayments {\n        payments {\n            ...PaymentFields\n        }\n    }\n": typeof types.GetPaymentsDocument,
  "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n": typeof types.DeleteStudentDocument,
  "\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentFields\n        }\n    }\n": typeof types.CreatePaymentDocument,
  "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n": typeof types.CreateStudentDocument,
  "\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        note\n        students {\n            id\n            fullName\n        }\n    }\n": typeof types.GroupFieldsFragmentDoc,
  "\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        attendances {\n            ...AttendanceFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n": typeof types.StudentFieldsFragmentDoc,
  "\n    fragment PaymentFields on Payment {\n        id\n        amount\n        date\n        lessonsPerPayment\n    }\n": typeof types.PaymentFieldsFragmentDoc,
  "\n    fragment LessonFields on Lesson {\n        id\n        groupId\n        startDateTime\n        attendances {\n            ...AttendanceFields\n        }\n    }\n": typeof types.LessonFieldsFragmentDoc,
  "\n    fragment AttendanceFields on Attendance {\n        id\n        studentId\n        present\n        lesson {\n            id\n            startDateTime\n        }\n    }\n": typeof types.AttendanceFieldsFragmentDoc,
  "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n": typeof types.RefreshTokensDocument,
  "\n    query GetGroups {\n        groups {\n            ...GroupFields\n        }\n    }\n": typeof types.GetGroupsDocument,
  "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupFields\n            lessons {\n                ...LessonFields\n            }\n        }\n    }\n": typeof types.GetGroupDocument,
  "\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n": typeof types.GetStudentsDocument,
  "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentFields\n            phone\n            birthDate\n            note\n            group {\n                id\n                defaultPrice\n            }\n            attendances {\n                ...AttendanceFields\n            }\n            payments {\n                ...PaymentFields\n            }\n        }\n    }\n": typeof types.GetStudentDocument,
  "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n": typeof types.GoogleLoginDocument,
  "\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n": typeof types.GetInitialDataDocument,
};
const documents: Documents = {
  "\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n": types.DeleteGroupDocument,
  "\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonFields\n        }\n    }\n": types.CreateLessonDocument,
  "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n": types.CreateGroupDocument,
  "\n    query GetPayments {\n        payments {\n            ...PaymentFields\n        }\n    }\n": types.GetPaymentsDocument,
  "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n": types.DeleteStudentDocument,
  "\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentFields\n        }\n    }\n": types.CreatePaymentDocument,
  "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n": types.CreateStudentDocument,
  "\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        note\n        students {\n            id\n            fullName\n        }\n    }\n": types.GroupFieldsFragmentDoc,
  "\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        attendances {\n            ...AttendanceFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n": types.StudentFieldsFragmentDoc,
  "\n    fragment PaymentFields on Payment {\n        id\n        amount\n        date\n        lessonsPerPayment\n    }\n": types.PaymentFieldsFragmentDoc,
  "\n    fragment LessonFields on Lesson {\n        id\n        groupId\n        startDateTime\n        attendances {\n            ...AttendanceFields\n        }\n    }\n": types.LessonFieldsFragmentDoc,
  "\n    fragment AttendanceFields on Attendance {\n        id\n        studentId\n        present\n        lesson {\n            id\n            startDateTime\n        }\n    }\n": types.AttendanceFieldsFragmentDoc,
  "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n": types.RefreshTokensDocument,
  "\n    query GetGroups {\n        groups {\n            ...GroupFields\n        }\n    }\n": types.GetGroupsDocument,
  "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupFields\n            lessons {\n                ...LessonFields\n            }\n        }\n    }\n": types.GetGroupDocument,
  "\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n": types.GetStudentsDocument,
  "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentFields\n            phone\n            birthDate\n            note\n            group {\n                id\n                defaultPrice\n            }\n            attendances {\n                ...AttendanceFields\n            }\n            payments {\n                ...PaymentFields\n            }\n        }\n    }\n": types.GetStudentDocument,
  "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n": types.GoogleLoginDocument,
  "\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n": types.GetInitialDataDocument,
};

/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 *
 *
 * @example
 * ```ts
 * const query = graphql(`query GetUser($id: ID!) { user(id: $id) { name } }`);
 * ```
 *
 * The query argument is unknown!
 * Please regenerate the types.
 */
export function graphql(source: string): unknown;

/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n"): (typeof documents)["\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetPayments {\n        payments {\n            ...PaymentFields\n        }\n    }\n"): (typeof documents)["\n    query GetPayments {\n        payments {\n            ...PaymentFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n"): (typeof documents)["\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        note\n        students {\n            id\n            fullName\n        }\n    }\n"): (typeof documents)["\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        note\n        students {\n            id\n            fullName\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        attendances {\n            ...AttendanceFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n"): (typeof documents)["\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        attendances {\n            ...AttendanceFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment PaymentFields on Payment {\n        id\n        amount\n        date\n        lessonsPerPayment\n    }\n"): (typeof documents)["\n    fragment PaymentFields on Payment {\n        id\n        amount\n        date\n        lessonsPerPayment\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment LessonFields on Lesson {\n        id\n        groupId\n        startDateTime\n        attendances {\n            ...AttendanceFields\n        }\n    }\n"): (typeof documents)["\n    fragment LessonFields on Lesson {\n        id\n        groupId\n        startDateTime\n        attendances {\n            ...AttendanceFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment AttendanceFields on Attendance {\n        id\n        studentId\n        present\n        lesson {\n            id\n            startDateTime\n        }\n    }\n"): (typeof documents)["\n    fragment AttendanceFields on Attendance {\n        id\n        studentId\n        present\n        lesson {\n            id\n            startDateTime\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n"): (typeof documents)["\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetGroups {\n        groups {\n            ...GroupFields\n        }\n    }\n"): (typeof documents)["\n    query GetGroups {\n        groups {\n            ...GroupFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupFields\n            lessons {\n                ...LessonFields\n            }\n        }\n    }\n"): (typeof documents)["\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupFields\n            lessons {\n                ...LessonFields\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n"): (typeof documents)["\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentFields\n            phone\n            birthDate\n            note\n            group {\n                id\n                defaultPrice\n            }\n            attendances {\n                ...AttendanceFields\n            }\n            payments {\n                ...PaymentFields\n            }\n        }\n    }\n"): (typeof documents)["\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentFields\n            phone\n            birthDate\n            note\n            group {\n                id\n                defaultPrice\n            }\n            attendances {\n                ...AttendanceFields\n            }\n            payments {\n                ...PaymentFields\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n"): (typeof documents)["\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n"): (typeof documents)["\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n        payments {\n            ...PaymentFields\n        }\n    }\n"];

export function graphql(source: string) {
  return (documents as any)[source] ?? {};
}

export type DocumentType<TDocumentNode extends DocumentNode<any, any>> = TDocumentNode extends DocumentNode<infer TType, any> ? TType : never;
