import { graphql } from '@/src/graphql/__generated__';

export const STUDENT_CORE_FIELDS = graphql(`
  fragment StudentCoreFields on Student {
    id
    fullName
    phone
    birthdate
    note
  }
`);

export const GROUP_CORE_FIELDS = graphql(`
  fragment GroupCoreFields on Group {
    id
    name
    defaultPrice
    note
  }
`);

export const LESSON_CORE_FIELDS = graphql(`
  fragment LessonCoreFields on Lesson {
    id
    startDateTime
  }
`);

export const PAYMENT_CORE_FIELDS = graphql(`
  fragment PaymentCoreFields on Payment {
    id
    amount
    date
    lessonsPerPayment
  }
`);

export const ATTENDANCE_CORE_FIELDS = graphql(`
    fragment AttendanceCoreFields on Attendance {
        id
        present
    }
`);

export const PAYMENT_DETAILS_FIELDS = graphql(`
  fragment PaymentDetailsFields on Payment {
    ...PaymentCoreFields
    student {
      ...StudentCoreFields
    }
  }
`);

export const GROUP_DETAILS_FIELDS = graphql(`
    fragment GroupDetailsFields on Group {
        ...GroupCoreFields
        students {
            ...StudentCoreFields
        }
        lessons {
            ...LessonCoreFields
        }
    }
`);

export const STUDENT_DETAILS_FIELDS = graphql(`
  fragment StudentDetailsFields on Student {
    ...StudentCoreFields
    group {
      ...GroupCoreFields
    }
    attendances {
      ...AttendanceCoreFields
      lesson {
        ...LessonCoreFields
      }
    }
    payments {
      ...PaymentCoreFields
    }
  }
`);

export const LESSON_DETAILS_FIELDS = graphql(`
    fragment LessonDetailsFields on Lesson {
        ...LessonCoreFields
        group {
            ...GroupCoreFields
            students {
                ...StudentCoreFields
            }
        }
        attendances {
            ...AttendanceCoreFields
            student {
                ...StudentCoreFields
            }
        }
    }
`);
