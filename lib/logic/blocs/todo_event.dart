import 'package:equatable/equatable.dart';
import '../../data/models/todo_model.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {
  const LoadTodos();
}

class AddTodoEvent extends TodoEvent {
  final String title;
  const AddTodoEvent(this.title);
  @override
  List<Object?> get props => [title];
}

class EditTodoEvent extends TodoEvent {
  final Todo todo;
  const EditTodoEvent(this.todo);
  @override
  List<Object?> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final Todo todo;
  const DeleteTodoEvent(this.todo);
  @override
  List<Object?> get props => [todo];
}

class SyncTodosEvent extends TodoEvent {
  const SyncTodosEvent();
}
