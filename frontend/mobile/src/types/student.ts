import type { components } from '@/src/api/generated/openapi';

export type StudentStatus =
  components['schemas']['StudentOverviewResponse']['statuses'][number];

export type StudentOverview = components['schemas']['StudentOverviewResponse'];

export type StudentDetails = components['schemas']['StudentDetailsResponse'];
