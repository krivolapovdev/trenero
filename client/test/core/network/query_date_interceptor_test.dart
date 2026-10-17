import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/extensions/date_time_extension.dart';
import 'package:phone/core/network/query_date_interceptor.dart';

void main() {
  const interceptor = QueryDateInterceptor();

  test('appends local offset to query param timestamp without offset', () {
    final options = RequestOptions(
      queryParameters: {'from': '2026-10-01T00:00:00.000'},
    );
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    final expectedOffset = DateTime.parse('2026-10-01T00:00:00.000')
        .timeZoneOffsetFormatted;
    expect(
      options.queryParameters['from'],
      '2026-10-01T00:00:00.000$expectedOffset',
    );
  });

  test('leaves plain dates alone (e.g. birthdate)', () {
    final options = RequestOptions(
      queryParameters: {'birthdate': '1998-05-15'},
    );
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.queryParameters['birthdate'], '1998-05-15');
  });

  test('leaves timestamps that already have offset or Z alone', () {
    final options = RequestOptions(
      queryParameters: {
        'utc': '2026-10-01T00:00:00.000Z',
        'withOffset': '2026-10-01T00:00:00.000+03:00',
      },
    );
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.queryParameters['utc'], '2026-10-01T00:00:00.000Z');
    expect(
      options.queryParameters['withOffset'],
      '2026-10-01T00:00:00.000+03:00',
    );
  });

  test('leaves non-date parameters alone', () {
    final options = RequestOptions(
      queryParameters: {'page': 1, 'name': 'Ivan', 'active': true},
    );
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.queryParameters['page'], 1);
    expect(options.queryParameters['name'], 'Ivan');
    expect(options.queryParameters['active'], true);
  });
}
