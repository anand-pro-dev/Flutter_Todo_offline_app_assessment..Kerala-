import 'todo_model.dart';

enum SyncAction { add, update, delete }

class SyncOperation {
  final SyncAction action;
  final Todo todo;

  SyncOperation({required this.action, required this.todo});
}
