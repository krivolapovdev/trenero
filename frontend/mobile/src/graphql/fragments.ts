import { graphql } from '@/src/graphql/__generated__';

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
        phone
        note
        birthdate
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
        startDateTime
        group {
            id
        }
        attendances {
            ...AttendanceFields
        }
    }
`);

export const ATTENDANCE_FIELDS = graphql(`
    fragment AttendanceFields on Attendance {
        id
        present
        student {
            id
        }
        lesson {
            id
            startDateTime
            group {
                id
            }
        }
    }
`);
