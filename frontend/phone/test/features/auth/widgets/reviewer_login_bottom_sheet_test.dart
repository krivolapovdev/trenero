import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/storage/token_storage.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/auth/pages/auth_page.dart';
import 'package:phone/features/auth/services/google_auth_service.dart';
import 'package:phone/features/auth/services/reviewer_auth_service.dart';
import 'package:phone/features/auth/widgets/reviewer_login_bottom_sheet.dart';
import 'package:phone/generated/models/jwt_response.dart';
import 'package:phone/generated/models/login_response.dart';
import 'package:phone/generated/models/user_response.dart';
import 'package:phone/generated/reviewer_auth_controller/reviewer_auth_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

/// Records the reviewer keys and answers like the backend does.
class _FakeReviewerAuthClient implements ReviewerAuthControllerClient {
  /// When set, [login] waits for it before answering.
  Completer<void>? gate;

  /// When set, [login] throws it instead of answering.
  Object? error;

  final List<String> keys = [];

  @override
  Future<LoginResponse> login({required String xReviewerKey}) async {
    keys.add(xReviewerKey);

    final gate = this.gate;
    if (gate != null) await gate.future;

    final error = this.error;
    if (error != null) throw error;

    return LoginResponse(
      user: const UserResponse(id: 'reviewer-1', email: 'REVIEWER@TRENERO.ORG'),
      jwtTokens: const JwtResponse(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    );
  }
}

/// Answers the Google sign in without touching the platform channels.
class _FakeGoogleAuthService implements GoogleAuthService {
  @override
  Future<String?> getGoogleIdToken() async => null;

  @override
  Future<void> signOut() async {}
}

/// Keeps the tokens in memory instead of the platform secure storage.
class _FakeTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  String? get accessToken => _accessToken;

  @override
  void setAccessToken(String? token) => _accessToken = token;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

Widget _providers(
  Widget child, {
  required _FakeReviewerAuthClient reviewerClient,
  required _FakeTokenStorage tokenStorage,
}) => ProviderScope(
  overrides: [
    reviewerAuthServiceProvider.overrideWithValue(reviewerClient),
    googleAuthServiceProvider.overrideWithValue(_FakeGoogleAuthService()),
    tokenStorageProvider.overrideWithValue(tokenStorage),
  ],
  child: TranslationProvider(child: child),
);

/// Hosts the sheet behind a button, the way the pages open it.
Widget _sheetHost(
  Widget sheet, {
  required _FakeReviewerAuthClient reviewerClient,
  required _FakeTokenStorage tokenStorage,
}) => _providers(
  MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => AppBottomSheet.show(context: context, child: sheet),
          child: const Text('open sheet'),
        ),
      ),
    ),
  ),
  reviewerClient: reviewerClient,
  tokenStorage: tokenStorage,
);

/// Opens the reviewer sheet the way the auth page does.
Future<void> _openSheet(
  WidgetTester tester, {
  required _FakeReviewerAuthClient reviewerClient,
  required _FakeTokenStorage tokenStorage,
}) async {
  await tester.pumpWidget(
    _sheetHost(
      const ReviewerLoginBottomSheet(),
      reviewerClient: reviewerClient,
      tokenStorage: tokenStorage,
    ),
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

TextButton _loginButton(WidgetTester tester) => tester.widget<TextButton>(
  find.descendant(
    of: find.byType(ReviewerLoginBottomSheet),
    matching: find.byType(TextButton),
  ),
);

Future<void> _login(WidgetTester tester, String reviewerKey) async {
  await tester.enterText(find.byType(TextField), reviewerKey);
  await tester.pump();

  await tester.tap(find.text(t.auth.login));
  await tester.pump();
}

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  testWidgets('the reviewer key field and the login button are offered', (
    tester,
  ) async {
    await _openSheet(
      tester,
      reviewerClient: _FakeReviewerAuthClient(),
      tokenStorage: _FakeTokenStorage(),
    );

    expect(find.text(t.auth.reviewerKey), findsOneWidget);
    expect(find.text(t.auth.login), findsOneWidget);
  });

  testWidgets('the login button is disabled until a reviewer key is entered', (
    tester,
  ) async {
    await _openSheet(
      tester,
      reviewerClient: _FakeReviewerAuthClient(),
      tokenStorage: _FakeTokenStorage(),
    );

    expect(_loginButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'secret');
    await tester.pump();

    expect(_loginButton(tester).onPressed, isNotNull);
  });

  testWidgets('an accepted reviewer key logs in and closes the sheet', (
    tester,
  ) async {
    final reviewerClient = _FakeReviewerAuthClient();
    final tokenStorage = _FakeTokenStorage();

    await _openSheet(
      tester,
      reviewerClient: reviewerClient,
      tokenStorage: tokenStorage,
    );

    await _login(tester, ' secret ');

    expect(reviewerClient.keys, ['secret']);
    expect(tokenStorage.accessToken, 'access-token');
    expect(await tokenStorage.getRefreshToken(), 'refresh-token');

    await tester.pumpAndSettle();

    expect(find.byType(ReviewerLoginBottomSheet), findsNothing);
  });

  testWidgets('the form is locked while the reviewer key is verified', (
    tester,
  ) async {
    final reviewerClient = _FakeReviewerAuthClient()..gate = Completer<void>();

    await _openSheet(
      tester,
      reviewerClient: reviewerClient,
      tokenStorage: _FakeTokenStorage(),
    );

    await _login(tester, 'secret');

    expect(_loginButton(tester).onPressed, isNull);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    reviewerClient.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(ReviewerLoginBottomSheet), findsNothing);
  });

  testWidgets('a rejected reviewer key shows an error and keeps the sheet', (
    tester,
  ) async {
    final requestOptions = RequestOptions(path: '/api/v1/reviewer/login');
    final reviewerClient = _FakeReviewerAuthClient()
      ..error = DioException(
        requestOptions: requestOptions,
        response: Response<Object?>(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

    await _openSheet(
      tester,
      reviewerClient: reviewerClient,
      tokenStorage: _FakeTokenStorage(),
    );

    await _login(tester, 'wrong');
    await tester.pump();

    expect(find.byType(ReviewerLoginBottomSheet), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(_loginButton(tester).onPressed, isNotNull);

    // Waits for the snack bar to go away, otherwise its timer outlives the
    // test.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a long press on the lottie opens the reviewer sheet', (
    tester,
  ) async {
    // The auth page is laid out for a phone; the test font is wider than the
    // real one, so a viewport that fits the square lottie is used.
    tester.view.physicalSize = const Size(960, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _providers(
        const MaterialApp(home: AuthPage()),
        reviewerClient: _FakeReviewerAuthClient(),
        tokenStorage: _FakeTokenStorage(),
      ),
    );

    // The lottie loops, so the sheet is opened without `pumpAndSettle`.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(LottieBuilder), findsOneWidget);
    expect(find.byType(ReviewerLoginBottomSheet), findsNothing);

    await tester.longPress(find.byType(LottieBuilder));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ReviewerLoginBottomSheet), findsOneWidget);
    expect(find.text(t.auth.reviewerKey), findsOneWidget);
    expect(find.text(t.auth.login), findsOneWidget);
  });
}
