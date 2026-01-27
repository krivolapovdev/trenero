import type { components } from '@/src/api/generated/openapi';

export type StudentStatus =
  components['schemas']['StudentOverviewResponse']['statuses'][number];
