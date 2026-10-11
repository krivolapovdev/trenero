import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/finance/pages/transaction_list_page.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/page_transaction_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/generated/transaction_controller/transaction_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

class _FakeTransactionClient implements TransactionControllerClient {
  @override
  Future<PageTransactionResponse> getPaginatedTransactions({
    int? page = 1,
    int? size = 20,
  }) async => const PageTransactionResponse(content: [], totalElements: 0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStudentClient implements StudentControllerClient {
  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child) => ProviderScope(
  overrides: [
    transactionServiceProvider.overrideWithValue(_FakeTransactionClient()),
    studentServiceProvider.overrideWithValue(_FakeStudentClient()),
  ],
  child: TranslationProvider(child: MaterialApp(home: child)),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the app bar offers adding a new payment', (tester) async {
    await tester.pumpWidget(_wrap(const TransactionListPage()));
    await tester.pumpAndSettle();

    expect(find.byIcon(FluentIcons.savings_24_regular), findsOneWidget);
  });

  testWidgets('tapping the app bar action opens the create transaction sheet', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const TransactionListPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FluentIcons.savings_24_regular));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTransactionBottomSheet), findsOneWidget);
    expect(find.text(t.finance.createTransaction), findsOneWidget);
  });
}
