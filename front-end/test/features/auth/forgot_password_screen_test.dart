import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mor_che_frontend/features/auth/presentation/forgot_password_screen.dart';

void main() {
  testWidgets('affiche un ecran forgot password informatif', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    expect(find.text('Fonction bientot disponible'), findsOneWidget);
    expect(
      find.textContaining(
        'Aucun email n est envoye automatiquement dans la version actuelle.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retour a la connexion'), findsOneWidget);
  });
}
