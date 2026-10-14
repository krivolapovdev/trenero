import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/network/dates/timestamp_codec.dart';

/// True when the value carries the offset of a region, as the API writes a timestamp.
bool _hasOffset(String value) => RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value);

void main() {
  const codec = IsoTimestampCodec();

  group('toApi', () {
    test('stamps a local date time with the offset of the device region', () {
      final value = codec.toApi('2026-10-08T00:00:00.000');

      expect(value, startsWith('2026-10-08T00:00:00.000'));
      expect(_hasOffset(value), isTrue);
      expect(
        DateTime.parse(value).isAtSameMomentAs(DateTime(2026, 10, 8)),
        isTrue,
      );
    });

    test('reads a plain day as the midnight of that day', () {
      final value = codec.toApi('2026-12-01');

      expect(_hasOffset(value), isTrue);
      expect(
        DateTime.parse(value).isAtSameMomentAs(DateTime(2026, 12, 1)),
        isTrue,
      );
    });

    test('leaves a value that is not a timestamp of the device alone', () {
      expect(codec.toApi('Ivan Petrov'), 'Ivan Petrov');
      expect(codec.toApi('2010-05-01T'), '2010-05-01T');
      expect(
        codec.toApi('2026-10-08T00:00:00.000+03:00'),
        '2026-10-08T00:00:00.000+03:00',
      );
    });
  });

  group('toDevice', () {
    test('turns a timestamp of the API into the local time of the device', () {
      final value = codec.toDevice('2026-10-08T00:00:00+03:00');

      expect(
        value,
        DateTime.parse('2026-10-08T00:00:00+03:00').toLocal().toIso8601String(),
      );
      expect(value.endsWith('Z'), isFalse);
    });

    test('turns a timestamp of the API in UTC into the local time too', () {
      expect(
        codec.toDevice('2026-10-08T00:00:00Z'),
        DateTime.parse('2026-10-08T00:00:00Z').toLocal().toIso8601String(),
      );
    });

    test('leaves a plain day and a value that is not a timestamp alone', () {
      expect(codec.toDevice('2010-05-01'), '2010-05-01');
      expect(codec.toDevice('Ivan Petrov'), 'Ivan Petrov');
    });
  });
}
