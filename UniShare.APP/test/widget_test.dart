import 'package:flutter_test/flutter_test.dart';
import 'package:unishare/config/app_config.dart';
import 'package:unishare/main.dart';

void main() {
  testWidgets('App renders UniShare title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const UniShareApp(config: AppConfig.dev),
    );

    expect(find.text('UniShare'), findsWidgets);
    expect(find.text('Chia sẻ đồ dùng sinh viên'), findsOneWidget);
    expect(find.text('Env: dev'), findsOneWidget);
  });
}
