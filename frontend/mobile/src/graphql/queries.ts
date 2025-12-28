import { graphql } from '@/src/graphql/__generated__';

export const GET_GROUPS = graphql(`
    query GetGroups {
        groups {
            ...GroupFields
        }
    }
`);

export const GET_STUDENTS = graphql(`
    query GetStudents {
        students {
            ...StudentFields
        }
    }
`);
