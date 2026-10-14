import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/network/dates/datetime_mapper.dart';
import 'package:phone/core/network/dates/timestamp_codec.dart';

/// A codec that marks the values it is given, so the walk of the mapper can be observed on its own.
final class _MarkingCodec implements TimestampCodec {
  const new();

  @override
  String toApi(String value) => 'api:$value';

  @override
  String toDevice(String value) => 'device:$value';
}

void main() {
  const mapper = DateTimeMapper(
    fields: DateTimeFields(<String>{'date', 'paidUntil'}),
    codec: _MarkingCodec(),
  );

  group('toApi', () {
    test('writes the declared fields through the codec', () {
      final data = <String, dynamic>{'date': '2026-10-08', 'amount': 100};

      expect(mapper.toApi(data), <String, dynamic>{
        'date': 'api:2026-10-08',
        'amount': 100,
      });
    });

    test('leaves a field that does not carry a moment alone', () {
      final data = <String, dynamic>{'birthdate': '2010-05-01'};

      expect(mapper.toApi(data), <String, dynamic>{'birthdate': '2010-05-01'});
    });

    test('walks into a nested object and a list', () {
      final data = <String, dynamic>{
        'paymentDetails': <String, dynamic>{'paidUntil': '2026-11-08'},
        'students': <dynamic>[
          <String, dynamic>{'date': '2026-10-08', 'fullName': 'Ivan'},
        ],
      };

      expect(mapper.toApi(data), <String, dynamic>{
        'paymentDetails': <String, dynamic>{'paidUntil': 'api:2026-11-08'},
        'students': <dynamic>[
          <String, dynamic>{'date': 'api:2026-10-08', 'fullName': 'Ivan'},
        ],
      });
    });

    test('leaves a value that is not a string alone', () {
      final data = <String, dynamic>{'date': 42, 'paidUntil': null};

      expect(mapper.toApi(data), <String, dynamic>{
        'date': 42,
        'paidUntil': null,
      });
    });
  });

  group('toDevice', () {
    test('writes the declared fields through the codec', () {
      final data = <String, dynamic>{'date': '2026-10-08T00:00:00Z'};

      expect(mapper.toDevice(data), <String, dynamic>{
        'date': 'device:2026-10-08T00:00:00Z',
      });
    });

    test('walks into a list of objects', () {
      final data = <dynamic>[
        <String, dynamic>{'paidUntil': '2026-11-08T00:00:00Z'},
      ];

      expect(mapper.toDevice(data), <dynamic>[
        <String, dynamic>{'paidUntil': 'device:2026-11-08T00:00:00Z'},
      ]);
    });

    test('leaves a value that is not a tree alone', () {
      expect(mapper.toDevice('Ivan Petrov'), 'Ivan Petrov');
      expect(mapper.toDevice(null), isNull);
    });
  });

  test('writes a value that stands on its own through the codec', () {
    expect(mapper.toApiValue('2026-10-08'), 'api:2026-10-08');
  });
}
