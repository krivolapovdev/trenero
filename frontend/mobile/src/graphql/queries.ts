import { graphql } from '@/src/graphql/__generated__';

export const GET_GROUPS = graphql(`
    query GetGroups {
        groups {
            ...GroupDetailsFields
        }
    }
`);

export const GET_GROUP = graphql(`
    query GetGroup($id: UUID!) {
        group(id: $id) {
            ...GroupDetailsFields
        }
    }
`);

export const GET_STUDENTS = graphql(`
    query GetStudents {
        students {
            ...StudentDetailsFields
        }
    }
`);

export const GET_STUDENT = graphql(`
    query GetStudent($id: UUID!) {
        student(id: $id) {
            ...StudentDetailsFields
        }
    }
`);

export const GET_LESSON = graphql(`
    query GetLesson($id: UUID!) {
        lesson(id: $id) {
            ...LessonDetailsFields
        }
    }
`);

export const GET_PAYMENT = graphql(`
    query GetPayment($id: UUID!) {
        payment(id: $id) {
            ...PaymentDetailsFields
        }
    }
`);
