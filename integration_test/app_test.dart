import 'package:app4_receitas/ui/recipes/recipes_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app4_receitas/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth E2E Test', () {
    testWidgets("realizar cadastro", (tester) async {
      app.main();

      await tester.pumpAndSettle();

      final emailField = find.byKey(ValueKey("emailField"));
      final passwordField = find.byKey(ValueKey("passwordField"));
      final submitButton = find.byKey(ValueKey("submitButton"));

      await tester.enterText(emailField, "contaAtiva");
      await tester.enterText(passwordField, "contaAtiva");
      await tester.pump();

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byType(RecipesView), findsOneWidget);
    });
  });
}
