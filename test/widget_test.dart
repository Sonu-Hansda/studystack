import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studystack/main.dart';
import 'package:studystack/repositories/authentication.dart';
import 'package:studystack/repositories/database.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    AuthenticationRepository authenticationRepository =
        AuthenticationRepository();
    DatabaseRepository databaseRepository = DatabaseRepository();
    await tester.pumpWidget(MyApp(
      authenticationRepository: authenticationRepository,
      databaseRepository: databaseRepository,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
