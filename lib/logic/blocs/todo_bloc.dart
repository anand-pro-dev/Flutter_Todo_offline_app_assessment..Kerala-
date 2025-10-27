import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/todo_repository.dart';
import '../../data/models/todo_model.dart';
import '../cubits/connectivity_cubit.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repo;
  final ConnectivityCubit connectivityCubit;
  StreamSubscription<bool>? _connSub;
  Timer? _backgroundTimer;

  TodoBloc({required this.repo, required this.connectivityCubit})
    : super(TodoInitial()) {
    on<LoadTodos>(_onLoad);
    on<AddTodoEvent>(_onAdd);
    on<EditTodoEvent>(_onEdit);
    on<DeleteTodoEvent>(_onDelete);
    on<SyncTodosEvent>(_onSync);

    // Listen connectivity changes, trigger immediate sync when online and start periodic background sync
    _connSub = connectivityCubit.connectivityStream.listen((online) {
      if (online) {
        add(const SyncTodosEvent());
        _startBackgroundSync();
      } else {
        _stopBackgroundSync();
      }
    });

    // Optionally start background sync if already online
    if (connectivityCubit.state) _startBackgroundSync();
  }

  Future<void> _onLoad(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    final online = connectivityCubit.state;
    try {
      final list = await repo.fetchTodos(isOnline: online);
      emit(TodoLoaded(todos: list, syncing: false));
    } catch (e) {
      // fallback to local read if fetch fails
      try {
        final local = await repo.db.getTodos();
        emit(TodoLoaded(todos: local, syncing: false));
      } catch (err) {
        emit(TodoError('Failed to load todos: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAdd(AddTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final current = (state as TodoLoaded).todos;
      final isOnline = connectivityCubit.state;
      final newTodo = Todo(
        title: event.title,
        completed: false,
        isSynced: isOnline,
      );
      try {
        await repo.addTodo(newTodo, isOnline: isOnline);
      } catch (_) {
        // errors already handled in repo; we still proceed to reload from local DB
      }
      // reload to ensure DB-assigned ids show up and ordering consistent
      final refreshed = await repo.fetchTodos(isOnline: isOnline);
      emit(TodoLoaded(todos: refreshed, syncing: false));
    }
  }

  Future<void> _onEdit(EditTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final isOnline = connectivityCubit.state;
      try {
        await repo.updateTodo(event.todo, isOnline: isOnline);
      } catch (_) {}
      final refreshed = await repo.fetchTodos(isOnline: isOnline);
      emit(TodoLoaded(todos: refreshed, syncing: false));
    }
  }

  Future<void> _onDelete(DeleteTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final isOnline = connectivityCubit.state;
      try {
        await repo.deleteTodo(event.todo.id!, isOnline: isOnline);
      } catch (_) {}
      final refreshed = await repo.fetchTodos(isOnline: isOnline);
      emit(TodoLoaded(todos: refreshed, syncing: false));
    }
  }

  Future<void> _onSync(SyncTodosEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final current = (state as TodoLoaded).todos;
      emit(TodoLoaded(todos: current, syncing: true));
      try {
        if (connectivityCubit.state) {
          await repo.syncPendingOps();
          final refreshed = await repo.fetchTodos(isOnline: true);
          emit(TodoLoaded(todos: refreshed, syncing: false));
          return;
        } else {
          emit(TodoLoaded(todos: current, syncing: false));
        }
      } catch (e) {
        // fetch latest local on failure
        final local = await repo.db.getTodos();
        emit(TodoLoaded(todos: local, syncing: false));
      }
    } else {
      // if not loaded, perform a load
      add(const LoadTodos());
    }
  }

  void _startBackgroundSync() {
    _backgroundTimer?.cancel();
    // run a sync every 30 seconds while online
    _backgroundTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (connectivityCubit.state) add(const SyncTodosEvent());
    });
  }

  void _stopBackgroundSync() {
    _backgroundTimer?.cancel();
  }

  @override
  Future<void> close() {
    _connSub?.cancel();
    _backgroundTimer?.cancel();
    return super.close();
  }
}
