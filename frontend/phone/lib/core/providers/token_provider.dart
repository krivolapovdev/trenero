import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String? token) {
    state = token;
  }
}

final tokenProvider = NotifierProvider<TokenNotifier, String?>(
  TokenNotifier.new,
);
