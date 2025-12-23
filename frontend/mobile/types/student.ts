export type StudentResponse = {
  id: string;
  fullName: string;
  phone?: string;
  birthDate?: string;
  note?: string;
  isAttending?: boolean;
  isPaid?: boolean;
  group?: {
    id: string;
    name: string;
  };
};
