import {graphql} from '@/src/graphql/__generated__';

export const GROUP_FIELDS = graphql(`
    fragment GroupFields on Group {
        id
        name
        defaultPrice
        note
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
        attendances {
            ...AttendanceFields
        }
        payments {
            ...PaymentFields
        }
    }
`);

export const PAYMENT_FIELDS = graphql(`
    fragment PaymentFields on Payment {
        id
        amount
        date
        lessonsPerPayment
    }
`);

export const LESSON_FIELDS = graphql(`
    fragment LessonFields on Lesson {
        id
        groupId
        startDateTime
        attendances {
            ...AttendanceFields
        }
    }
`);

export const ATTENDANCE_FIELDS = graphql(`
    fragment AttendanceFields on Attendance {
        id
        studentId
        present
        lesson {
            id
            startDateTime
        }
    }
`);
