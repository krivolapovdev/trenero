import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/extensions/date_time_extension.dart';

void main() {
  group('DateTimeExtension', () {
    test('timeZoneOffsetFormatted returns properly padded string', () {
      final now = DateTime.now();
      expect(now.timeZoneOffsetFormatted, matches(r'^[+-]\d{2}:\d{2}$'));
    });

    test('toIso8601StringWithOffset appends offset for local time', () {
      final local = DateTime(2026, 10, 14, 15, 30);
      final formatted = local.toIso8601StringWithOffset();

      expect(formatted, startsWith('2026-10-14T15:30:00.000'));
      expect(formatted, endsWith(local.timeZoneOffsetFormatted));
    });

    test('toIso8601StringWithOffset retains Z for UTC', () {
      final utc = DateTime.utc(2026, 10, 14, 15, 30);
      final formatted = utc.toIso8601StringWithOffset();

      expect(formatted, '2026-10-14T15:30:00.000Z');
    });

    test('toIsoDateString formats as yyyy-MM-dd', () {
      final date = DateTime(2026, 5, 4);
      expect(date.toIsoDateString(), '2026-05-04');
    });
  });
}
