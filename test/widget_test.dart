import 'package:flutter_test/flutter_test.dart';
import 'package:team_task_management_app/main.dart';
import 'package:team_task_management_app/services/database_service.dart';

void main() {
  testWidgets('Task management app smoke test', (WidgetTester tester) async {
    // Initialize mock database service
    final databaseService = MockDatabaseService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(databaseService: databaseService));

    // Let the initial stream builder resolve and settle UI
    await tester.pumpAndSettle();

    // Verify that the title of the app is shown.
    expect(find.text('SyncTask'), findsOneWidget);

    // Verify that the sample task from MockDatabaseService is rendered.
    expect(find.text('Design Dashboard UI'), findsOneWidget);
  });
}
