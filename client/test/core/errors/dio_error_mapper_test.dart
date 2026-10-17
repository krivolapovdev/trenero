import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:phone/i18n/strings_ru.g.dart';

const String _takenName = 'A student named "Odin" already exists';

DioException _failedRequest(
  int statusCode, {
  Object? data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final requestOptions = RequestOptions(path: '/api/v1/students');

  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: Response<Object?>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

Map<String, Object?> _problemDetail({
  required int status,
  required String title,
  required String detail,
  String? code,
}) => {
  'type': 'about:blank',
  'title': title,
  'status': status,
  'detail': detail,
  'instance': '/api/v1/students',
  'code': ?code,
};

DioException _takenNameError() => _failedRequest(
  409,
  data: _problemDetail(
    status: 409,
    title: 'Conflict',
    detail: _takenName,
    code: 'STUDENT_NAME_NOT_UNIQUE',
  ),
);

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('a taken name is named by the code of the backend', () {
    final mapped = _takenNameError().toAppException();

    expect(mapped, isA<ConflictException>());
    expect(mapped.code, AppErrorCode.studentNameNotUnique);
  });

  test('a named failure is worded in the language of the reader', () {
    final mapped = _takenNameError().toAppException();

    expect(
      mapped.localizedMessage(t),
      'A student with this name already exists.',
    );
    expect(
      mapped.localizedMessage(TranslationsRu()),
      'Ученик с таким именем уже существует.',
    );
  });

  test('a conflict the backend does not name is worded by the status', () {
    final error = _failedRequest(
      409,
      data: _problemDetail(
        status: 409,
        title: 'Conflict',
        detail: 'A database integrity constraint violation occurred',
      ),
    );

    final mapped = error.toAppException();

    expect(mapped.code, AppErrorCode.conflict);
    expect(mapped.localizedMessage(t), t.errors.conflict);
  });

  test('each name the backend reports is worded on its own', () {
    final group = _failedRequest(
      409,
      data: _problemDetail(
        status: 409,
        title: 'Conflict',
        detail: 'A group named "Group A" already exists',
        code: 'GROUP_NAME_NOT_UNIQUE',
      ),
    );

    final mapped = group.toAppException();

    expect(mapped.code, AppErrorCode.groupNameNotUnique);
    expect(mapped.localizedMessage(t), t.errors.groupNameNotUnique);
    expect(
      mapped.localizedMessage(TranslationsRu()),
      'Группа с таким названием уже существует.',
    );
  });

  test('a rejected form keeps the message of every failing field', () {
    final error = _failedRequest(
      400,
      data: {
        ..._problemDetail(
          status: 400,
          title: 'Validation Failed',
          detail: 'One or more fields in the request failed validation',
        ),
        'errors': [
          {'field': 'fullName', 'message': 'must not be blank'},
          {'field': 'phone', 'message': 'must match the phone pattern'},
        ],
      },
    );

    final mapped = error.toAppException();

    expect(mapped, isA<ValidationException>());
    // The fields are more precise than any wording the app can pick, so they
    // win over the status and stay as the backend wrote them.
    expect(mapped.code, isNull);
    expect(
      mapped.localizedMessage(t),
      'must not be blank\nmust match the phone pattern',
    );
  });

  test('a rejected request without failing fields is worded by the status', () {
    final error = _failedRequest(
      400,
      data: _problemDetail(
        status: 400,
        title: 'Bad Request',
        detail: 'paidUntil must not be before the payment date',
      ),
    );

    final mapped = error.toAppException();

    expect(mapped.code, AppErrorCode.validation);
    expect(mapped.localizedMessage(t), t.errors.validation);
  });

  test(
    'a status the app does not name on its own is worded as a bad request',
    () {
      final error = _failedRequest(
        422,
        data: _problemDetail(
          status: 422,
          title: 'Unprocessable Entity',
          detail: 'The lesson is not on the day of the group',
        ),
      );

      expect(error.toAppException().localizedMessage(t), t.errors.badRequest);
    },
  );

  test('an expired session is worded as unauthorized', () {
    final error = _failedRequest(
      401,
      data: _problemDetail(
        status: 401,
        title: 'Unauthorized',
        detail: 'Authentication failed or token is invalid',
      ),
    );

    final mapped = error.toAppException();

    expect(mapped, isA<UnauthorizedException>());
    expect(mapped.code, AppErrorCode.unauthorized);
    expect(mapped.localizedMessage(t), t.errors.unauthorized);
  });

  test('a forbidden request is worded as denied', () {
    final error = _failedRequest(
      403,
      data: _problemDetail(
        status: 403,
        title: 'Forbidden',
        detail: 'You do not have permission to access this resource',
      ),
    );

    final mapped = error.toAppException();

    expect(mapped, isA<ForbiddenException>());
    expect(mapped.localizedMessage(t), t.errors.forbidden);
  });

  test('a record that is gone is worded by the status', () {
    final error = _failedRequest(
      404,
      data: _problemDetail(
        status: 404,
        title: 'Not Found',
        detail: 'Student not found with id={1} for user={2}',
      ),
    );

    final mapped = error.toAppException();

    expect(mapped, isA<NotFoundException>());
    expect(mapped.localizedMessage(t), t.errors.notFound);
  });

  test('a broken server is worded by the status', () {
    final error = _failedRequest(
      500,
      data: _problemDetail(
        status: 500,
        title: 'Internal Server Error',
        detail: 'An unexpected error occurred. Please contact support or try again later.',
      ),
    );

    final mapped = error.toAppException();

    expect(mapped, isA<ServerException>());
    expect((mapped as ServerException).statusCode, 500);
    expect(mapped.localizedMessage(t), t.errors.server);
  });

  test('a code the app does not know falls back to the status', () {
    final error = _failedRequest(
      503,
      data: _problemDetail(
        status: 503,
        title: 'Service Unavailable',
        detail: 'The service is down for maintenance',
        code: 'SOMETHING_NEW',
      ),
    );

    expect(error.toAppException().localizedMessage(t), t.errors.server);
  });

  test('a failure without a problem body falls back to its own wording', () {
    final error = _failedRequest(502, data: '<html>Bad Gateway</html>');

    final mapped = error.toAppException();

    expect(mapped, isA<ServerException>());
    expect((mapped as ServerException).statusCode, 502);
    expect(mapped.localizedMessage(t), t.errors.server);
  });

  test('a lost connection is worded as being offline', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/api/v1/students'),
      type: DioExceptionType.connectionError,
    );

    final mapped = error.toAppException();

    expect(mapped, isA<NetworkException>());
    expect(mapped.localizedMessage(t), t.errors.network);
  });

  test('a slow server is worded as a timeout', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/api/v1/students'),
      type: DioExceptionType.receiveTimeout,
    );

    expect(error.toAppException().localizedMessage(t), t.errors.timeout);
  });

  test('the message of a failure is read whatever shape it has', () {
    expect(
      _takenNameError().userMessage(t),
      'A student with this name already exists.',
    );
    expect(
      _takenNameError().userMessage(TranslationsRu()),
      'Ученик с таким именем уже существует.',
    );
    expect(const NetworkException().userMessage(t), t.errors.network);
    expect('plain failure'.userMessage(t), 'plain failure');
    expect(null.userMessage(t), isEmpty);
  });
}
