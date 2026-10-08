import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/storage/token_storage.dart';
import 'package:phone/features/auth/providers/auth_notifier.dart';
import 'package:phone/features/auth/repository/auth_repository.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';

const String _groupId = 'group-a';
const String _studentId = 'student-1';

final _date = DateTime(2025, 8, 22);

/// Answers the group endpoints with a single group and counts the summary
/// requests, so a test can tell a cached list from a fresh one.
class _FakeGroupService implements GroupControllerClient {
  int summaryCalls = 0;

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() async {
    summaryCalls++;

    return [
      GroupSummaryResponse(id: _groupId, name: 'Group A', createdAt: _date),
    ];
  }

  @override
  Future<GroupResponse> createGroup({required CreateGroupRequest body}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteGroup({required String groupId}) =>
      throw UnimplementedError();

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError();

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) => throw UnimplementedError();

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) => throw UnimplementedError();

  @override
  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

/// Answers the student endpoints with a single student, counting the summary
/// requests like [_FakeGroupService] does.
class _FakeStudentService implements StudentControllerClient {
  int summaryCalls = 0;

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async {
    summaryCalls++;

    return [
      StudentSummaryResponse(
        id: _studentId,
        fullName: 'Ivan Petrov',
        createdAt: _date,
        statuses: const [StudentStatus.paid],
        studentGroup: GroupResponse(
          id: _groupId,
          name: 'Group A',
          createdAt: _date,
        ),
      ),
    ];
  }

  @override
  Future<StudentResponse> createStudent({required CreateStudentRequest body}) =>
      throw UnimplementedError();

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> getStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<List<StudentResponse>> getStudents() => throw UnimplementedError();

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

/// Keeps the tokens in memory instead of the platform secure storage.
class _FakeTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  String? get accessToken => _accessToken;

  @override
  void setAccessToken(String? token) => _accessToken = token;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

/// Ends the session the way [AuthRepository.logout] does, without the platform
/// Google sign in.
class _FakeAuthRepository implements AuthRepository {
  new(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> logout() => _tokenStorage.clear();

  @override
  Future<bool> tryAutoLogin() async => false;

  @override
  Future<String?> getGoogleIdToken() => throw UnimplementedError();

  @override
  Future<bool> authenticateGoogleTokenWithBackend(String idToken) =>
      throw UnimplementedError();

  @override
  Future<bool> authenticateReviewerKeyWithBackend(String reviewerKey) =>
      throw UnimplementedError();
}

/// The switch the auth gate performs, with the pages of the shell reduced to
/// the data they read.
class _Session extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authNotifierProvider);

    if (status.value != AuthStatus.authenticated) {
      return const Text('auth page');
    }

    return const Column(children: [_GroupList(), _StudentList()]);
  }
}

class _GroupList extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupListControllerProvider).value ?? const [];

    return Text('groups: ${groups.map((group) => group.name).join(', ')}');
  }
}

class _StudentList extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentListControllerProvider).value ?? const [];

    return Text(
      'students: ${students.map((student) => student.fullName).join(', ')}',
    );
  }
}

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: const MaterialApp(home: Scaffold(body: _Session())),
);

/// Puts an image that never completes in the cache of the painting binding.
void _cacheAnImage() => PaintingBinding.instance.imageCache.putIfAbsent(
  const ValueKey('cached-image'),
  () => OneFrameImageStreamCompleter(Completer<ImageInfo>().future),
);

void main() {
  testWidgets('logout clears every cache of the session', (tester) async {
    final groupService = _FakeGroupService();
    final studentService = _FakeStudentService();
    final tokenStorage = _FakeTokenStorage();
    final container = ProviderContainer(
      overrides: [
        groupServiceProvider.overrideWithValue(groupService),
        studentServiceProvider.overrideWithValue(studentService),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(tokenStorage),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('auth page'), findsOneWidget);

    await tokenStorage.saveTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    // Signs in the way the reviewer key and Google do.
    container.read(authNotifierProvider.notifier).markAuthenticated();
    await tester.pumpAndSettle();

    expect(find.text('groups: Group A'), findsOneWidget);
    expect(find.text('students: Ivan Petrov'), findsOneWidget);
    expect(groupService.summaryCalls, 1);
    expect(studentService.summaryCalls, 1);

    // A filter, and an image in the cache of the device.
    container
        .read(studentFilterControllerProvider.notifier)
        .toggleGroup(_groupId);
    final imageCache = PaintingBinding.instance.imageCache;
    _cacheAnImage();

    expect(container.read(studentFilterControllerProvider).activeCount, 1);
    expect(imageCache.pendingImageCount, 1);

    // Signs out, the way the settings page does.
    final logout = container.read(authNotifierProvider.notifier).logout();
    await tester.pumpAndSettle();
    await logout;

    expect(find.text('auth page'), findsOneWidget);

    // The tokens are gone.
    expect(tokenStorage.accessToken, isNull);
    expect(await tokenStorage.getRefreshToken(), isNull);

    // The lists of the repositories are gone.
    expect(container.read(groupRepositoryProvider).getCachedGroups(), isEmpty);
    expect(
      container.read(studentRepositoryProvider).getCachedStudents(),
      isEmpty,
    );

    // The images and the state of the pages are gone.
    expect(imageCache.pendingImageCount, 0);
    expect(imageCache.liveImageCount, 0);
    expect(container.read(studentFilterControllerProvider).isEmpty, isTrue);

    // Nothing was requested again while the shell was going away.
    expect(groupService.summaryCalls, 1);
    expect(studentService.summaryCalls, 1);

    // The next session starts from scratch.
    container.read(authNotifierProvider.notifier).markAuthenticated();
    await tester.pumpAndSettle();

    expect(groupService.summaryCalls, 2);
    expect(studentService.summaryCalls, 2);
  });
}
