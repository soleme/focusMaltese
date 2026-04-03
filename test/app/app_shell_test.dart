import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_maltese/app/app.dart';

void main() {
  testWidgets('하단 탭으로 말티즈 화면에 이동할 수 있다', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusMalteseApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('집중'), findsOneWidget);
    expect(find.text('말티즈'), findsOneWidget);

    await tester.tap(find.text('말티즈'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('말티즈 상태'), findsOneWidget);
    expect(find.text('MVP 이후 예정 기능'), findsOneWidget);
  });

  testWidgets('설정 탭으로 이동할 수 있다', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusMalteseApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('설정'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('집중 경험'), findsOneWidget);
    await tester.drag(find.byType(Scrollable), const Offset(0, -700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('데이터 관리'), findsOneWidget);
  });
}
