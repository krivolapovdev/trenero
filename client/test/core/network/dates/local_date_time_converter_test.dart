import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/extensions/date_time_extension.dart';
import 'package:phone/core/network/dates/local_date_time_converter.dart';

void main() {
  group('LocalDateTimeConverter', () {
    const converter = LocalDateTimeConverter();

    test('toJson formats local DateTime with timezone offset', () {
      final date = DateTime(2026, 10, 8, 14, 0);
      final json = converter.toJson(date);

      expect(json, '2026-10-08T14:00:00.000${date.timeZoneOffsetFormatted}');
    });

    test('fromJson converts UTC timestamp from API into local time', () {
      final parsed = converter.fromJson('2026-10-08T12:00:00Z');

      expect(parsed.isUtc, isFalse);
      expect(parsed.isAtSameMomentAs(DateTime.utc(2026, 10, 8, 12, 0)), isTrue);
    });

    test(
      'fromJson converts timestamp with foreign offset into device local time',
      () {
        final parsed = converter.fromJson('2026-10-08T12:00:00+03:00');

        expect(parsed.isUtc, isFalse);
        expect(
          parsed.isAtSameMomentAs(DateTime.parse('2026-10-08T12:00:00+03:00')),
          isTrue,
        );
      },
    );
  });

  group('LocalDateConverter', () {
    const converter = LocalDateConverter();

    test('toJson formats as yyyy-MM-dd without time or offset', () {
      final date = DateTime(1998, 5, 15);
      expect(converter.toJson(date), '1998-05-15');
    });

    test('fromJson parses plain date', () {
      final parsed = converter.fromJson('1998-05-15');
      expect(parsed.year, 1998);
      expect(parsed.month, 5);
      expect(parsed.day, 15);
    });
  });
}
