import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_maltese/features/timer/models/app_snapshot.dart';
import 'package:focus_maltese/features/timer/presentation/home_screen.dart';
import 'package:focus_maltese/features/timer/services/persistence_repository.dart';

class InMemoryRepository implements PersistenceRepository {
  AppSnapshot? snapshot;

  @override
  Future<void> clear() async {
    snapshot = null;
  }

  @override
  Future<AppSnapshot?> loadSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(AppSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

void main() {
  testWidgets('초기 화면에 프리셋과 시작 버튼이 보인다', (WidgetTester tester) async {
    final repository = InMemoryRepository();

    await tester.pumpWidget(
      MaterialApp(home: FocusHomeScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('25분 집중'), findsOneWidget);
    expect(find.text('50분 몰입'), findsOneWidget);
    expect(find.text('집중 시작'), findsOneWidget);
  });

  testWidgets('집중 시작 후 포기 버튼이 보인다', (WidgetTester tester) async {
    final repository = InMemoryRepository();

    await tester.pumpWidget(
      MaterialApp(home: FocusHomeScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('집중 시작'));
    await tester.tap(find.text('집중 시작'));
    await tester.pumpAndSettle();

    expect(find.text('포기하기'), findsOneWidget);
    expect(find.text('집중 중'), findsOneWidget);
  });
}
