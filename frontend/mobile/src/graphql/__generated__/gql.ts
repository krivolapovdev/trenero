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
  "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            id\n            name\n            defaultPrice\n            students {\n                id\n                fullName\n            }\n            lessons {\n                id\n                startDateTime\n            }\n        }\n    }\n": typeof types.GetGroupDocument,
  "\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n": typeof types.DeleteGroupDocument,
  "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n": typeof types.CreateGroupDocument,
  "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            id\n            fullName\n            phone\n            birthDate\n            note\n            group {\n                id\n                name\n            }\n            lastAttendance {\n                present\n            }\n            attendances {\n                id\n                present\n                createdAt\n            }\n            payments {\n                id\n                amount\n                createdAt\n            }\n        }\n    }\n": typeof types.GetStudentDocument,
  "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n": typeof types.DeleteStudentDocument,
  "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n": typeof types.CreateStudentDocument,
  "\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        students {\n            id\n            fullName\n        }\n    }\n": typeof types.GroupFieldsFragmentDoc,
  "\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        lastAttendance {\n            present\n        }\n    }\n": typeof types.StudentFieldsFragmentDoc,
  "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n": typeof types.RefreshTokensDocument,
  "\n    query GetGroups {\n        groups {\n            ...GroupFields\n        }\n    }\n": typeof types.GetGroupsDocument,
  "\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n": typeof types.GetStudentsDocument,
  "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n": typeof types.GoogleLoginDocument,
  "\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n    }\n": typeof types.GetInitialDataDocument,
};
const documents: Documents = {
  "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            id\n            name\n            defaultPrice\n            students {\n                id\n                fullName\n            }\n            lessons {\n                id\n                startDateTime\n            }\n        }\n    }\n": types.GetGroupDocument,
  "\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n": types.DeleteGroupDocument,
  "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n": types.CreateGroupDocument,
  "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            id\n            fullName\n            phone\n            birthDate\n            note\n            group {\n                id\n                name\n            }\n            lastAttendance {\n                present\n            }\n            attendances {\n                id\n                present\n                createdAt\n            }\n            payments {\n                id\n                amount\n                createdAt\n            }\n        }\n    }\n": types.GetStudentDocument,
  "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n": types.DeleteStudentDocument,
  "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n": types.CreateStudentDocument,
  "\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        students {\n            id\n            fullName\n        }\n    }\n": types.GroupFieldsFragmentDoc,
  "\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        lastAttendance {\n            present\n        }\n    }\n": types.StudentFieldsFragmentDoc,
  "\n    mutation RefreshTokens($input: RefreshTokenInput!) {\n        refreshTokens(input: $input) {\n            accessToken\n            refreshToken\n        }\n    }\n": types.RefreshTokensDocument,
  "\n    query GetGroups {\n        groups {\n            ...GroupFields\n        }\n    }\n": types.GetGroupsDocument,
  "\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n": types.GetStudentsDocument,
  "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n": types.GoogleLoginDocument,
  "\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n    }\n": types.GetInitialDataDocument,
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
export function graphql(source: "\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            id\n            name\n            defaultPrice\n            students {\n                id\n                fullName\n            }\n            lessons {\n                id\n                startDateTime\n            }\n        }\n    }\n"): (typeof documents)["\n    query GetGroup($id: UUID!) {\n        group(id: $id) {\n            id\n            name\n            defaultPrice\n            students {\n                id\n                fullName\n            }\n            lessons {\n                id\n                startDateTime\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n"): (typeof documents)["\n    mutation DeleteGroup($id: UUID!) {\n        deleteGroup(id: $id) {\n            id\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateGroup($input: CreateGroupInput!) {\n        createGroup(input: $input) {\n            ...GroupFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            id\n            fullName\n            phone\n            birthDate\n            note\n            group {\n                id\n                name\n            }\n            lastAttendance {\n                present\n            }\n            attendances {\n                id\n                present\n                createdAt\n            }\n            payments {\n                id\n                amount\n                createdAt\n            }\n        }\n    }\n"): (typeof documents)["\n    query GetStudent($id: UUID!) {\n        student(id: $id) {\n            id\n            fullName\n            phone\n            birthDate\n            note\n            group {\n                id\n                name\n            }\n            lastAttendance {\n                present\n            }\n            attendances {\n                id\n                present\n                createdAt\n            }\n            payments {\n                id\n                amount\n                createdAt\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n"): (typeof documents)["\n    mutation DeleteStudent($id: UUID!) {\n        deleteStudent(id: $id) {\n            id\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n"): (typeof documents)["\n    mutation CreateStudent($input: CreateStudentInput!) {\n        createStudent(input: $input) {\n            ...StudentFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        students {\n            id\n            fullName\n        }\n    }\n"): (typeof documents)["\n    fragment GroupFields on Group {\n        id\n        name\n        defaultPrice\n        students {\n            id\n            fullName\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        lastAttendance {\n            present\n        }\n    }\n"): (typeof documents)["\n    fragment StudentFields on Student {\n        id\n        fullName\n        group {\n            id\n            name\n        }\n        lastAttendance {\n            present\n        }\n    }\n"];
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
export function graphql(source: "\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n"): (typeof documents)["\n    query GetStudents {\n        students {\n            ...StudentFields\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n"): (typeof documents)["\n    mutation GoogleLogin($input: SocialLoginInput!) {\n        googleLogin(input: $input) {\n            user {\n                id\n                email\n            }\n            jwtTokens {\n                accessToken\n                refreshToken\n            }\n        }\n    }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n    }\n"): (typeof documents)["\n    query GetInitialData {\n        groups {\n            ...GroupFields\n        }\n        students {\n            ...StudentFields\n        }\n    }\n"];

export function graphql(source: string) {
  return (documents as any)[source] ?? {};
}

export type DocumentType<TDocumentNode extends DocumentNode<any, any>> = TDocumentNode extends DocumentNode<infer TType, any> ? TType : never;
