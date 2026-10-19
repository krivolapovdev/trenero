import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/students/controllers/create_student_controller.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:phone/i18n/strings_ru.g.dart';

const String _takenName = 'A student named "Odin" already exists';

// The answer the backend gives when the name of a student is already taken.
DioException _takenNameError() {
  final requestOptions = RequestOptions(path: '/api/v1/students');

  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: requestOptions,
      statusCode: 409,
      data: {
        'type': 'about:blank',
        'title': 'Conflict',
        'status': 409,
        'detail': _takenName,
        'instance': '/api/v1/students',
        'code': 'STUDENT_NAME_NOT_UNIQUE',
      },
    ),
  );
}

class _FakeStudentClient implements StudentControllerClient {
  DioException? error;
  final List<CreateStudentRequest> createBodies = [];

  @override
  Future<StudentResponse> createStudent({
    required CreateStudentRequest body,
  }) async {
    createBodies.add(body);

    final error = this.error;
    if (error != null) throw error;

    return StudentResponse(
      id: 'student-1',
      fullName: body.fullName,
      createdAt: DateTime(2026, 10, 13),
      free: body.free ?? false,
    );
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();
}

ProviderContainer _container(_FakeStudentClient client) {
  final container = ProviderContainer(
    overrides: [studentServiceProvider.overrideWithValue(client)],
  );
  addTearDown(container.dispose);

  return container;
}

Future<bool> _save(ProviderContainer container, {String fullName = 'Odin'}) =>
    container
        .read(createStudentControllerProvider.notifier)
        .saveStudent(
          fullName: fullName,
          birthdate: null,
          phone: null,
          note: null,
          free: false,
        );

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test(
    'a taken name fails the save with a message a person can read',
    () async {
      final client = _FakeStudentClient()..error = _takenNameError();
      final container = _container(client);

      final saved = await _save(container);
      final Object? failure = container
          .read(createStudentControllerProvider)
          .error;

      expect(saved, isFalse);
      expect(client.createBodies, hasLength(1));
      expect(failure, isA<ConflictException>());

      final error = failure as AppException;

      expect(error.code, AppErrorCode.studentNameNotUnique);
      expect(error.userMessage(t), 'A student with this name already exists.');
      expect(
        error.userMessage(TranslationsRu()),
        'Ученик с таким именем уже существует.',
      );
    },
  );

  test('the save trims the name before the request is sent', () async {
    final client = _FakeStudentClient();
    final container = _container(client);

    final saved = await _save(container, fullName: '  Odin  ');

    expect(saved, isTrue);
    expect(client.createBodies.single.fullName, 'Odin');
  });

  test('an empty name never reaches the server', () async {
    final client = _FakeStudentClient();
    final container = _container(client);

    final saved = await _save(container, fullName: '   ');

    expect(saved, isFalse);
    expect(client.createBodies, isEmpty);

    final Object? failure = container
        .read(createStudentControllerProvider)
        .error;

    expect(failure, isA<ValidationException>());
    expect(
      (failure as AppException).userMessage(TranslationsRu()),
      'Укажите имя ученика.',
    );
  });
}
