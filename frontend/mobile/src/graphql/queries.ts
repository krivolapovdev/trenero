import { graphql } from '@/src/graphql/__generated__';

export const GET_GROUPS = graphql(`
    query GetGroups {
        groups {
            ...GroupFields
        }
    }
`);

export const GET_GROUP = graphql(`
    query GetGroup($id: UUID!) {
        group(id: $id) {
            ...GroupFields
            lessons {
                ...LessonFields
            }
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

export const GET_STUDENT = graphql(`
    query GetStudent($id: UUID!) {
        student(id: $id) {
            ...StudentFields
            phone
            birthdate
            note
            group {
                id
                defaultPrice
            }
            attendances {
                ...AttendanceFields
            }
            payments {
                ...PaymentFields
            }
        }
    }
`);

export const GET_PAYMENT = graphql(`
    query GetPayment($id: UUID!) {
        payment(id: $id) {
            ...PaymentFields
            student {
                id
            }
        }
    }
`);

export const GET_LESSON = graphql(`
    query GetLesson($id: UUID!) {
        lesson(id: $id) {
            ...LessonFields
            group {
                id
                students {
                    id
                    fullName
                }
            }
            attendances {
                student { id }
                present
            }
        }
    }
`);
