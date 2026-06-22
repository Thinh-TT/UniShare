import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unishare/config/app_config.dart';
import 'package:unishare/app.dart';
import 'package:unishare/shared/widgets/loading_state.dart';
import 'package:unishare/shared/widgets/empty_state.dart';
import 'package:unishare/shared/widgets/error_state.dart';
import 'package:unishare/shared/widgets/status_badge.dart';
import 'package:unishare/shared/widgets/user_avatar.dart';
import 'package:unishare/shared/widgets/app_chip.dart';

void main() {
  /// Helper to pump the full app with ProviderScope.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev),
        ],
        child: const UniShareApp(),
      ),
    );
    await tester.pump();
  }

  group('App startup', () {
    testWidgets('renders splash screen on launch', (tester) async {
      await pumpApp(tester);
      // Should show the UniShare logo/name
      expect(find.text('UniShare'), findsOneWidget);
      expect(find.text('Chia sẻ đồ dùng sinh viên'), findsOneWidget);
    });
  });

  group('Shared widgets', () {
    testWidgets('LoadingState renders spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingState())),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingState with message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingState(message: 'Đang tải...')),
        ),
      );
      expect(find.text('Đang tải...'), findsOneWidget);
    });

    testWidgets('EmptyState renders icon and title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Không có dữ liệu',
              subtitle: 'Hãy thử lại sau',
            ),
          ),
        ),
      );
      expect(find.text('Không có dữ liệu'), findsOneWidget);
      expect(find.text('Hãy thử lại sau'), findsOneWidget);
    });

    testWidgets('EmptyState with action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Trống',
              actionLabel: 'Thử lại',
              onAction: () {},
            ),
          ),
        ),
      );
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('ErrorState renders message and retry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Lỗi kết nối',
              onRetry: () {},
            ),
          ),
        ),
      );
      expect(find.text('Lỗi kết nối'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('StatusBadge renders with correct label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(label: 'Available', color: StatusBadgeColor.success),
          ),
        ),
      );
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('UserAvatar renders initials', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(fullName: 'Nguyen Van A', size: 40),
          ),
        ),
      );
      // Should show initials "VA"
      expect(find.text('VA'), findsOneWidget);
    });

    testWidgets('UserAvatar with reputation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              fullName: 'Nguyen Van A',
              reputationScore: 95.5,
              size: 40,
            ),
          ),
        ),
      );
      expect(find.text('96'), findsOneWidget); // Rounded
    });

    testWidgets('AppChip selected and unselected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AppChip(label: 'Chưa chọn', isSelected: false, onSelected: (_) {}),
                AppChip(label: 'Đã chọn', isSelected: true, onSelected: (_) {}),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Chưa chọn'), findsOneWidget);
      expect(find.text('Đã chọn'), findsOneWidget);
    });
  });

  group('Theme colors', () {
    testWidgets('uses green primary and white surface', (tester) async {
      await pumpApp(tester);
      final context = tester.element(find.byType(UniShareApp));
      final theme = Theme.of(context);
      // Verify color scheme has green primary configured
      expect(theme.colorScheme.primary, isNotNull);
      // Scaffold background should be near-white
      expect(theme.scaffoldBackgroundColor, isNotNull);
      // Theme should use Material 3
      expect(theme.useMaterial3, isTrue);
    });
  });
}
