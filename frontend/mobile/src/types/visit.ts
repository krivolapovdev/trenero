import type { components } from '@/src/api/generated/openapi';

export type VisitStatus = NonNullable<
  components['schemas']['StudentVisit']['status']
>;

export const VisitStatusIcon: Record<VisitStatus, string> = {
  PRESENT: 'check-circle',
  ABSENT: 'close-circle',
  FREE: 'percent-circle',
  UNMARKED: 'help-circle-outline'
};

export const VisitStatusColor: Record<VisitStatus, string> = {
  PRESENT: '#4CAF50',
  ABSENT: '#F44336',
  FREE: '#FFB300',
  UNMARKED: '#9E9E9E'
};
