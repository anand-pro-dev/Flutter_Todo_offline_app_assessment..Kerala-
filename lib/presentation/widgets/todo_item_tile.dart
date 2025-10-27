import 'package:flutter/material.dart';
import '../../data/models/todo_model.dart';

typedef ToggleCallback = void Function(Todo todo);
typedef EditCallback = void Function(Todo todo);
typedef DeleteCallback = void Function(Todo todo);

class TodoItemTile extends StatelessWidget {
  final Todo todo;
  final ToggleCallback onToggle;
  final EditCallback onEdit;
  final DeleteCallback onDelete;

  const TodoItemTile({
    Key? key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusText = todo.isSynced ? (todo.completed ? '✅ completed' : '⏳ pending') : '⏳ pending • offline';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: IconButton(
          icon: Icon(todo.completed ? Icons.check_box : Icons.check_box_outline_blank),
          onPressed: () => onToggle(todo),
        ),
        title: Text(todo.title),
        subtitle: Text(statusText),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(todo)),
            IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(todo)),
          ],
        ),
      ),
    );
  }
}
