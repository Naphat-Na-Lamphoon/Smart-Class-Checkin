import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_class_checkin/main.dart';

void main() {
  testWidgets('App shows home title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SmartClassApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Smart Class Check-in'), findsOneWidget);
    expect(find.text('Check-in (Before Class)'), findsOneWidget);
  });
}
