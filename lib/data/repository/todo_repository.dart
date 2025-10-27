import '../models/todo_model.dart';
import '../models/sync_operation.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

class TodoRepository {
  final ApiService api;
  final LocalDbService db;

  TodoRepository({required this.api, required this.db});

  final List<SyncOperation> _pendingOps = [];

  Future<List<Todo>> fetchTodos({required bool isOnline}) async {
    if (isOnline) {
      final remoteTodos = await api.fetchTodos();
      await db.clear();
      for (final t in remoteTodos) {
        await db.insertTodo(t);
      }
      return remoteTodos;
    } else {
      return await db.getTodos();
    }
  }

  Future<void> addTodo(Todo todo, {required bool isOnline}) async {
    final localTodo = todo.copyWith(isSynced: isOnline);
    await db.insertTodo(localTodo);
    if (isOnline) {
      await api.addTodoRemote(todo);
    } else {
      _pendingOps.add(SyncOperation(action: SyncAction.add, todo: localTodo));
    }
  }

  Future<void> updateTodo(Todo todo, {required bool isOnline}) async {
    await db.updateTodo(todo);
    if (isOnline) {
      await api.updateTodoRemote(todo);
    } else {
      _pendingOps.add(SyncOperation(action: SyncAction.update, todo: todo));
    }
  }

  Future<void> deleteTodo(int id, {required bool isOnline}) async {
    await db.deleteTodo(id);
    if (isOnline) {
      await api.deleteTodoRemote(id);
    } else {
      _pendingOps.add(SyncOperation(
          action: SyncAction.delete,
          todo: Todo(id: id, title: '', completed: false)));
    }
  }

  Future<void> syncPendingOps() async {
    for (final op in List.from(_pendingOps)) {
      try {
        switch (op.action) {
          case SyncAction.add:
            await api.addTodoRemote(op.todo);
            break;
          case SyncAction.update:
            await api.updateTodoRemote(op.todo);
            break;
          case SyncAction.delete:
            await api.deleteTodoRemote(op.todo.id!);
            break;
        }
        op.todo.copyWith(isSynced: true);
        await db.updateTodo(op.todo);
        _pendingOps.remove(op);
      } catch (_) {}
    }
  }
}
