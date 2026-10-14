import 'package:phone/core/network/dates/timestamp_codec.dart';

/// The fields of the API that carry a moment in time.
///
/// `birthdate` is deliberately absent: it is a plain calendar day, not a moment, and both sides
/// write it as `yyyy-MM-dd`.
final class DateTimeFields {
  const new(this._fields);

  /// The fields the API carries as a moment.
  static const DateTimeFields api = DateTimeFields(<String>{
    'date',
    'paidUntil',
    'paidFrom',
    'createdAt',
    'updatedAt',
    'leftAt',
  });

  final Set<String> _fields;

  bool contains(String field) => _fields.contains(field);
}

/// Writes the timestamps of a JSON tree into the shape of the other side: the shape of the API for
/// the values the device sends, the shape of the device for the values the API sends back.
final class DateTimeMapper {
  const new({
    this.fields = DateTimeFields.api,
    this.codec = const IsoTimestampCodec(),
  });

  final DateTimeFields fields;
  final TimestampCodec codec;

  /// The API shape of a timestamp that stands on its own, such as a query parameter.
  String toApiValue(String value) => codec.toApi(value);

  /// The tree with every timestamp of a field of [fields] written the way the API carries it.
  Object? toApi(Object? data) => _map(data, codec.toApi);

  /// The tree with every timestamp of a field of [fields] written the way the device reads it.
  Object? toDevice(Object? data) => _map(data, codec.toDevice);

  Object? _map(Object? data, String Function(String value) write) {
    if (data is Map) {
      for (final field in data.keys.toList()) {
        final value = data[field];

        if (value is String && fields.contains('$field')) {
          data[field] = write(value);
        } else if (value is Map || value is List) {
          data[field] = _map(value, write);
        }
      }

      return data;
    }

    if (data is List) {
      for (var index = 0; index < data.length; index++) {
        data[index] = _map(data[index], write);
      }

      return data;
    }

    return data;
  }
}
