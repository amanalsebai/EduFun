// اختبار دخان بسيط: يتحقق أن التطبيق يُبنى دون رمي استثناءات.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edufun/app.dart';

void main() {
  testWidgets('التطبيق يُبنى دون أخطاء', (WidgetTester tester) async {
    await tester.pumpWidget(SmartGamesApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
