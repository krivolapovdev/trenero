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
  "\n    mutation DeleteLesson($id: UUID!) {\n        deleteLesson(id: $id) {\n            id\n        }\n    }\n": typeof types.DeleteLessonDocument,
  "\n    mutation UpdateLesson($id: UUID!, $input: UpdateLessonInput!) {\n        updateLesson(id: $id, input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n": typeof types.UpdateLessonDocument,
    "\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n": typeof types.CreateLessonDocument,
  "\n    mutation UpdateGroup($id: UUID!, $input: UpdateGroupInput!) {\n        updateGroup(id: $id, input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n": typeof types.UpdateGroupDocument,
    "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n": typeof types.CreateGroupDocument,
    "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n": typeof types.DeleteStudentDocument,
  "\n    mutation UpdatePayment($id: UUID!, $input: UpdatePaymentInput!) {\n        updatePayment(id: $id, input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n": typeof types.UpdatePaymentDocument,
    "\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n": typeof types.CreatePaymentDocument,
  "\n    mutation EditStudent($id: UUID!, $input: UpdateStudentInput!) {\n        updateStudent(id: $id, input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n": typeof types.EditStudentDocument,
    "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n": typeof types.CreateStudentDocument,
    "\n    mutation DeletePayment($id: UUID!) {\n        deletePayment(id: $id) {\n            id\n        }\n    }\n": typeof types.DeletePaymentDocument,
    "\n  fragment StudentCoreFields on Student {\n    id\n    fullName\n    phone\n    birthdate\n    note\n  }\n": typeof types.StudentCoreFieldsFragmentDoc,
    "\n  fragment GroupCoreFields on Group {\n    id\n    name\n    defaultPrice\n    note\n  }\n": typeof types.GroupCoreFieldsFragmentDoc,
    "\n  fragment LessonCoreFields on Lesson {\n    id\n    startDateTime\n  }\n": typeof types.LessonCoreFieldsFragmentDoc,
    "\n  fragment PaymentCoreFields on Payment {\n    id\n    amount\n    date\n    lessonsPerPayment\n  }\n": typeof types.PaymentCoreFieldsFragmentDoc,
  "\n    fragment VisitCoreFields on Visit {\n        id\n        present\n    }\n": typeof types.VisitCoreFieldsFragmentDoc,
    "\n  fragment PaymentDetailsFields on Payment {\n    ...PaymentCoreFields\n    student {\n      ...StudentCoreFields\n    }\n  }\n": typeof types.PaymentDetailsFieldsFragmentDoc,
    "\n    fragment GroupDetailsFields on Group {\n        ...GroupCoreFields\n        students {\n            ...StudentCoreFields\n        }\n        lessons {\n            ...LessonCoreFields\n        }\n    }\n": typeof types.GroupDetailsFieldsFragmentDoc,
  "\n    fragment StudentDetailsFields on Student {\n        ...StudentCoreFields\n        group {\n            ...GroupCoreFields\n        }\n        visits {\n            ...VisitCoreFields\n            lesson {\n                ...LessonCoreFields\n            }\n        }\n        payments {\n            ...PaymentCoreFields\n        }\n    }\n": typeof types.StudentDetailsFieldsFragmentDoc,
  "\n    fragment LessonDetailsFields on Lesson {\n        ...LessonCoreFields\n        group {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n        visits {\n            ...VisitCoreFields\n            student {\n                ...StudentCoreFields\n            }\n        }\n    }\n": typeof types.LessonDetailsFieldsFragmentDoc,
    "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n": typeof types.RefreshTokensDocument,
    "\n    query GetGroups {\n        groups {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n    }\n": typeof types.GetGroupsDocument,
    "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupDetailsFields\n        }\n    }\n": typeof types.GetGroupDocument,
    "\n    query GetStudents {\n        students {\n            ...StudentDetailsFields\n        }\n    }\n": typeof types.GetStudentsDocument,
    "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentDetailsFields\n        }\n    }\n": typeof types.GetStudentDocument,
    "\n    query GetLesson($id: UUID!) {\n        lesson(id: $id) {\n            ...LessonDetailsFields\n        }\n    }\n": typeof types.GetLessonDocument,
    "\n    query GetPayment($id: UUID!) {\n        payment(id: $id) {\n            ...PaymentDetailsFields\n        }\n    }\n": typeof types.GetPaymentDocument,
    "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n": typeof types.GoogleLoginDocument,
    "\n    query GetInitialData {\n        groups {\n            ...GroupDetailsFields\n        }\n        students {\n            ...StudentDetailsFields\n        }\n    }\n": typeof types.GetInitialDataDocument,
};
const documents: Documents = {
    "\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n": types.DeleteGroupDocument,
  "\n    mutation DeleteLesson($id: UUID!) {\n        deleteLesson(id: $id) {\n            id\n        }\n    }\n": types.DeleteLessonDocument,
  "\n    mutation UpdateLesson($id: UUID!, $input: UpdateLessonInput!) {\n        updateLesson(id: $id, input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n": types.UpdateLessonDocument,
    "\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n": types.CreateLessonDocument,
  "\n    mutation UpdateGroup($id: UUID!, $input: UpdateGroupInput!) {\n        updateGroup(id: $id, input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n": types.UpdateGroupDocument,
    "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n": types.CreateGroupDocument,
    "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n": types.DeleteStudentDocument,
  "\n    mutation UpdatePayment($id: UUID!, $input: UpdatePaymentInput!) {\n        updatePayment(id: $id, input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n": types.UpdatePaymentDocument,
    "\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n": types.CreatePaymentDocument,
  "\n    mutation EditStudent($id: UUID!, $input: UpdateStudentInput!) {\n        updateStudent(id: $id, input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n": types.EditStudentDocument,
    "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n": types.CreateStudentDocument,
    "\n    mutation DeletePayment($id: UUID!) {\n        deletePayment(id: $id) {\n            id\n        }\n    }\n": types.DeletePaymentDocument,
    "\n  fragment StudentCoreFields on Student {\n    id\n    fullName\n    phone\n    birthdate\n    note\n  }\n": types.StudentCoreFieldsFragmentDoc,
    "\n  fragment GroupCoreFields on Group {\n    id\n    name\n    defaultPrice\n    note\n  }\n": types.GroupCoreFieldsFragmentDoc,
    "\n  fragment LessonCoreFields on Lesson {\n    id\n    startDateTime\n  }\n": types.LessonCoreFieldsFragmentDoc,
    "\n  fragment PaymentCoreFields on Payment {\n    id\n    amount\n    date\n    lessonsPerPayment\n  }\n": types.PaymentCoreFieldsFragmentDoc,
  "\n    fragment VisitCoreFields on Visit {\n        id\n        present\n    }\n": types.VisitCoreFieldsFragmentDoc,
    "\n  fragment PaymentDetailsFields on Payment {\n    ...PaymentCoreFields\n    student {\n      ...StudentCoreFields\n    }\n  }\n": types.PaymentDetailsFieldsFragmentDoc,
    "\n    fragment GroupDetailsFields on Group {\n        ...GroupCoreFields\n        students {\n            ...StudentCoreFields\n        }\n        lessons {\n            ...LessonCoreFields\n        }\n    }\n": types.GroupDetailsFieldsFragmentDoc,
  "\n    fragment StudentDetailsFields on Student {\n        ...StudentCoreFields\n        group {\n            ...GroupCoreFields\n        }\n        visits {\n            ...VisitCoreFields\n            lesson {\n                ...LessonCoreFields\n            }\n        }\n        payments {\n            ...PaymentCoreFields\n        }\n    }\n": types.StudentDetailsFieldsFragmentDoc,
  "\n    fragment LessonDetailsFields on Lesson {\n        ...LessonCoreFields\n        group {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n        visits {\n            ...VisitCoreFields\n            student {\n                ...StudentCoreFields\n            }\n        }\n    }\n": types.LessonDetailsFieldsFragmentDoc,
    "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n": types.RefreshTokensDocument,
    "\n    query GetGroups {\n        groups {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n    }\n": types.GetGroupsDocument,
    "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupDetailsFields\n        }\n    }\n": types.GetGroupDocument,
    "\n    query GetStudents {\n        students {\n            ...StudentDetailsFields\n        }\n    }\n": types.GetStudentsDocument,
    "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentDetailsFields\n        }\n    }\n": types.GetStudentDocument,
    "\n    query GetLesson($id: UUID!) {\n        lesson(id: $id) {\n            ...LessonDetailsFields\n        }\n    }\n": types.GetLessonDocument,
    "\n    query GetPayment($id: UUID!) {\n        payment(id: $id) {\n            ...PaymentDetailsFields\n        }\n    }\n": types.GetPaymentDocument,
    "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n": types.GoogleLoginDocument,
    "\n    query GetInitialData {\n        groups {\n            ...GroupDetailsFields\n        }\n        students {\n            ...StudentDetailsFields\n        }\n    }\n": types.GetInitialDataDocument,
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
export function graphql(source: "\n    mutation DeleteLesson($id: UUID!) {\n        deleteLesson(id: $id) {\n            id\n        }\n    }\n"): (typeof documents)["\n    mutation DeleteLesson($id: UUID!) {\n        deleteLesson(id: $id) {\n            id\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation UpdateLesson($id: UUID!, $input: UpdateLessonInput!) {\n        updateLesson(id: $id, input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation UpdateLesson($id: UUID!, $input: UpdateLessonInput!) {\n        updateLesson(id: $id, input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateLesson($input: CreateLessonInput!) {\n        createLesson(input: $input) {\n            ...LessonDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation UpdateGroup($id: UUID!, $input: UpdateGroupInput!) {\n        updateGroup(id: $id, input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation UpdateGroup($id: UUID!, $input: UpdateGroupInput!) {\n        updateGroup(id: $id, input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n"): (typeof documents)["\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation UpdatePayment($id: UUID!, $input: UpdatePaymentInput!) {\n        updatePayment(id: $id, input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation UpdatePayment($id: UUID!, $input: UpdatePaymentInput!) {\n        updatePayment(id: $id, input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreatePayment($input: CreatePaymentInput!) {\n        createPayment(input: $input) {\n            ...PaymentDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation EditStudent($id: UUID!, $input: UpdateStudentInput!) {\n        updateStudent(id: $id, input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation EditStudent($id: UUID!, $input: UpdateStudentInput!) {\n        updateStudent(id: $id, input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation DeletePayment($id: UUID!) {\n        deletePayment(id: $id) {\n            id\n        }\n    }\n"): (typeof documents)["\n    mutation DeletePayment($id: UUID!) {\n        deletePayment(id: $id) {\n            id\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  fragment StudentCoreFields on Student {\n    id\n    fullName\n    phone\n    birthdate\n    note\n  }\n"): (typeof documents)["\n  fragment StudentCoreFields on Student {\n    id\n    fullName\n    phone\n    birthdate\n    note\n  }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  fragment GroupCoreFields on Group {\n    id\n    name\n    defaultPrice\n    note\n  }\n"): (typeof documents)["\n  fragment GroupCoreFields on Group {\n    id\n    name\n    defaultPrice\n    note\n  }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  fragment LessonCoreFields on Lesson {\n    id\n    startDateTime\n  }\n"): (typeof documents)["\n  fragment LessonCoreFields on Lesson {\n    id\n    startDateTime\n  }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  fragment PaymentCoreFields on Payment {\n    id\n    amount\n    date\n    lessonsPerPayment\n  }\n"): (typeof documents)["\n  fragment PaymentCoreFields on Payment {\n    id\n    amount\n    date\n    lessonsPerPayment\n  }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment VisitCoreFields on Visit {\n        id\n        present\n    }\n"): (typeof documents)["\n    fragment VisitCoreFields on Visit {\n        id\n        present\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  fragment PaymentDetailsFields on Payment {\n    ...PaymentCoreFields\n    student {\n      ...StudentCoreFields\n    }\n  }\n"): (typeof documents)["\n  fragment PaymentDetailsFields on Payment {\n    ...PaymentCoreFields\n    student {\n      ...StudentCoreFields\n    }\n  }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment GroupDetailsFields on Group {\n        ...GroupCoreFields\n        students {\n            ...StudentCoreFields\n        }\n        lessons {\n            ...LessonCoreFields\n        }\n    }\n"): (typeof documents)["\n    fragment GroupDetailsFields on Group {\n        ...GroupCoreFields\n        students {\n            ...StudentCoreFields\n        }\n        lessons {\n            ...LessonCoreFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment StudentDetailsFields on Student {\n        ...StudentCoreFields\n        group {\n            ...GroupCoreFields\n        }\n        visits {\n            ...VisitCoreFields\n            lesson {\n                ...LessonCoreFields\n            }\n        }\n        payments {\n            ...PaymentCoreFields\n        }\n    }\n"): (typeof documents)["\n    fragment StudentDetailsFields on Student {\n        ...StudentCoreFields\n        group {\n            ...GroupCoreFields\n        }\n        visits {\n            ...VisitCoreFields\n            lesson {\n                ...LessonCoreFields\n            }\n        }\n        payments {\n            ...PaymentCoreFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment LessonDetailsFields on Lesson {\n        ...LessonCoreFields\n        group {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n        visits {\n            ...VisitCoreFields\n            student {\n                ...StudentCoreFields\n            }\n        }\n    }\n"): (typeof documents)["\n    fragment LessonDetailsFields on Lesson {\n        ...LessonCoreFields\n        group {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n        visits {\n            ...VisitCoreFields\n            student {\n                ...StudentCoreFields\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n"): (typeof documents)["\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetGroups {\n        groups {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n    }\n"): (typeof documents)["\n    query GetGroups {\n        groups {\n            ...GroupCoreFields\n            students {\n                ...StudentCoreFields\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupDetailsFields\n        }\n    }\n"): (typeof documents)["\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            ...GroupDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetStudents {\n        students {\n            ...StudentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    query GetStudents {\n        students {\n            ...StudentDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            ...StudentDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetLesson($id: UUID!) {\n        lesson(id: $id) {\n            ...LessonDetailsFields\n        }\n    }\n"): (typeof documents)["\n    query GetLesson($id: UUID!) {\n        lesson(id: $id) {\n            ...LessonDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetPayment($id: UUID!) {\n        payment(id: $id) {\n            ...PaymentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    query GetPayment($id: UUID!) {\n        payment(id: $id) {\n            ...PaymentDetailsFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n"): (typeof documents)["\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetInitialData {\n        groups {\n            ...GroupDetailsFields\n        }\n        students {\n            ...StudentDetailsFields\n        }\n    }\n"): (typeof documents)["\n    query GetInitialData {\n        groups {\n            ...GroupDetailsFields\n        }\n        students {\n            ...StudentDetailsFields\n        }\n    }\n"];

export function graphql(source: string) {
  return (documents as any)[source] ?? {};
}

export type DocumentType<TDocumentNode extends DocumentNode<any, any>> = TDocumentNode extends DocumentNode<  infer TType,  any>  ? TType  : never;
