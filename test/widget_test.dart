import 'package:flutter_test/flutter_test.dart';

import 'package:elegance_gowns/main.dart';

void main() {
  testWidgets('App launches on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EleganceGownsApp());
    await tester.pump();

    expect(find.text('Elegance'), findsOneWidget);
    expect(find.text('GOWNS'), findsOneWidget);
  });
}
