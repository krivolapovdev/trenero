import { graphql } from '@/src/graphql/__generated__';

export const GROUP_FIELDS = graphql(`
    fragment GroupFields on Group {
        id
        name
        defaultPrice
        students {
            id
            fullName
        }
    }
`);

export const STUDENT_FIELDS = graphql(`
    fragment StudentFields on Student {
        id
        fullName
        group {
            id
            name
        }
        lastAttendance {
            present
        }
    }
`);
