import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/models/group_report_period.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/group_report_response.dart';

final groupReportProvider =
    AsyncNotifierProvider.family<
      GroupReportController,
      GroupReportResponse,
      GroupReportPeriod
    >(GroupReportController.new);

class GroupReportController extends AsyncNotifier<GroupReportResponse> {
  new(this.period);

  final GroupReportPeriod period;

  @override
  Future<GroupReportResponse> build() async {
    final repository = ref.watch(groupRepositoryProvider);
    return repository.getGroupReport(
      groupId: period.groupId,
      year: period.year,
      month: period.month,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
