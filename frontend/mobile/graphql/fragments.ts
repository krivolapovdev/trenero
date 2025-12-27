import { gql } from '@apollo/client';

export const GROUP_FIELDS = gql`
    fragment GroupFields on Group {
        id
        name
        defaultPrice
        students {
            id
            fullName
        }
    }
`;

export const STUDENT_FIELDS = gql`
    fragment StudentFields on Student {
        id
        fullName
        group {
            id
            name
        }
    }
`;
