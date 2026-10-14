import 'dart:convert';

/// The wire shape of a request body.
abstract interface class JsonPayload {
  /// The JSON object a body carries, or `null` when the body is not a JSON object.
  Map<String, dynamic>? asJson(Object? body);
}

/// A [JsonPayload] for the bodies the clients build: a map, or an object that writes itself as one
/// through `toJson`.
final class JsonPayloadCodec implements JsonPayload {
  const new();

  @override
  Map<String, dynamic>? asJson(Object? body) {
    if (body is Map<String, dynamic>) return body;

    try {
      final decoded = jsonDecode(jsonEncode(body));

      return decoded is Map<String, dynamic> ? decoded : null;
    } on Object {
      return null;
    }
  }
}
