import 'package:flutter_test/flutter_test.dart';
import 'package:zyra/main.dart';
import 'package:zyra/splash/splash_screen.dart';

void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SplashScreen());
  });
}
