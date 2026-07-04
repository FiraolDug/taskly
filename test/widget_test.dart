import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Taskly/app/core/widgets/task_edit_sheet.dart';
import 'package:Taskly/app/modal/task_model.dart';

void main() {
  testWidgets('Task edit sheet keeps title and description separate', (
    WidgetTester tester,
  ) async {
    late Task savedTask;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskEditSheet(
            task: Task(
              taskName: 'Old title',
              description: 'Old description',
              done: false,
            ),
            isEditing: true,
            onSave: (task) {
              savedTask = task;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'New title');
    await tester.enterText(find.byType(TextField).at(1), 'New description');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedTask.taskName, 'New title');
    expect(savedTask.description, 'New description');
  });
}
