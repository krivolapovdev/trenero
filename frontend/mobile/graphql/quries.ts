import { gql } from '@apollo/client';
import { GROUP_FIELDS, STUDENT_FIELDS } from '@/graphql/fragments';

export const GET_GROUPS = gql`
    query {
        groups {
            ...GroupFields
        }
    }
    ${GROUP_FIELDS}
`;

export const GET_STUDENTS = gql`
    query {
        students {
            ...StudentFields
        }
    }
    ${STUDENT_FIELDS}
`;
