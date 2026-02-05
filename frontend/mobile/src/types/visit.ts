import type { components } from '@/src/api/generated/openapi';

export type VisitStatus = NonNullable<
  components['schemas']['StudentVisit']['status']
>;

export type VisitType = NonNullable<
  components['schemas']['StudentVisit']['type']
>;
