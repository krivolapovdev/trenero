import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/network/api_date_interceptor.dart';
import 'package:phone/generated/models/create_transaction_request.dart';
import 'package:phone/generated/models/transaction_type.dart';

/// True when the value is an ISO-8601 timestamp that carries a region offset.
bool _hasOffset(String value) => RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value);

void main() {
  late Dio dio;
  late _RecordingAdapter adapter;

  setUp(() {
    adapter = _RecordingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..interceptors.add(const ApiDateInterceptor())
      ..httpClientAdapter = adapter;
  });

  test('a day of a typed request body leaves with the device offset', () async {
    final day = DateTime(2026, 10, 8);

    await dio.post<dynamic>(
      '/api/v1/transactions',
      data: CreateTransactionRequest(
        amount: 100,
        date: day,
        type: TransactionType.income,
      ),
    );

    final sent = adapter.lastRequest!.data as Map<String, dynamic>;
    final date = sent['date'] as String;

    expect(_hasOffset(date), isTrue);
    expect(DateTime.parse(date).isAtSameMomentAs(day), isTrue);
  });

  test(
    'a plain day of a patch body becomes the midnight of that day',
    () async {
      await dio.patch<dynamic>(
        '/api/v1/transactions/1',
        data: <String, dynamic>{'amount': 100, 'date': '2026-12-01'},
      );

      final date =
          (adapter.lastRequest!.data as Map<String, dynamic>)['date'] as String;

      expect(_hasOffset(date), isTrue);
      expect(
        DateTime.parse(date).isAtSameMomentAs(DateTime(2026, 12, 1)),
        isTrue,
      );
    },
  );

  test('a birthdate stays a plain calendar day', () async {
    await dio.post<dynamic>(
      '/api/v1/students',
      data: <String, dynamic>{'fullName': 'Ivan', 'birthdate': '2010-05-01'},
    );

    expect(
      (adapter.lastRequest!.data as Map<String, dynamic>)['birthdate'],
      '2010-05-01',
    );
  });

  test('a nested payment detail is stamped as well', () async {
    await dio.post<dynamic>(
      '/api/v1/transactions',
      data: <String, dynamic>{
        'date': '2026-10-08T00:00:00.000',
        'paymentDetails': <String, dynamic>{'paidUntil': '2026-11-08'},
      },
    );

    final sent = adapter.lastRequest!.data as Map<String, dynamic>;
    final details = sent['paymentDetails'] as Map<String, dynamic>;

    expect(_hasOffset(sent['date'] as String), isTrue);
    expect(_hasOffset(details['paidUntil'] as String), isTrue);
  });

  test('a range the app asks for leaves with the device offset', () async {
    final from = DateTime(2026, 10);

    await dio.get<dynamic>(
      '/api/v1/groups/1/lessons',
      queryParameters: <String, dynamic>{
        'from': from.toIso8601String(),
        'to': from.toIso8601String(),
      },
    );

    final sent = adapter.lastRequest!.uri.queryParameters;
    final sentFrom = sent['from']!;

    expect(_hasOffset(sentFrom), isTrue);
    expect(DateTime.parse(sentFrom).isAtSameMomentAs(from), isTrue);
  });

  test('a day that comes back is the local time of the device', () async {
    adapter.body = '{"date":"2026-10-08T00:00:00+03:00"}';

    final response = await dio.get<dynamic>('/api/v1/transactions/1');
    final date = DateTime.parse(
      (response.data as Map<String, dynamic>)['date'] as String,
    );

    expect(date.isUtc, isFalse);
    expect(date, DateTime.parse('2026-10-08T00:00:00+03:00').toLocal());
  });

  test('a list of days that comes back is converted too', () async {
    adapter.body = '[{"paidUntil":"2026-11-08T00:00:00+03:00"}]';

    final response = await dio.get<dynamic>('/api/v1/students/1/payments');
    final first =
        (response.data as List<dynamic>).first as Map<String, dynamic>;
    final paidUntil = DateTime.parse(first['paidUntil'] as String);

    expect(paidUntil.isUtc, isFalse);
    expect(paidUntil, DateTime.parse('2026-11-08T00:00:00+03:00').toLocal());
  });

  test('a day nested in a list of a response is converted too', () async {
    adapter.body =
        '{"paymentDetails":{"paidUntil":"2026-11-08T00:00:00+03:00"},'
        '"students":[{"date":"2026-10-08T00:00:00+03:00"}]}';

    final response = await dio.get<dynamic>('/api/v1/transactions/1');
    final data = response.data as Map<String, dynamic>;
    final details = data['paymentDetails'] as Map<String, dynamic>;
    final student =
        (data['students'] as List<dynamic>).first as Map<String, dynamic>;

    expect(DateTime.parse(details['paidUntil'] as String).isUtc, isFalse);
    expect(DateTime.parse(student['date'] as String).isUtc, isFalse);
  });

  test('a day without an offset in a response is left alone', () async {
    adapter.body = '{"birthdate":"2010-05-01"}';

    final response = await dio.get<dynamic>('/api/v1/students/1');

    expect((response.data as Map<String, dynamic>)['birthdate'], '2010-05-01');
  });
}

/// An adapter that answers with a canned body and remembers the request it got.
class _RecordingAdapter implements HttpClientAdapter {
  String body = '{}';
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;

    return ResponseBody.fromString(
      body,
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
