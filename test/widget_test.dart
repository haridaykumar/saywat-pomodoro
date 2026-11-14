import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saywat_pomodoro/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SaywatPomodoroApp());
    expect(find.text('Saywat Pomodoro'), findsOneWidget);
  });
}