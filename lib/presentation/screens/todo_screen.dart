import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_tracker/presentation/utils/toast.dart';
import '../../logic/blocs/todo_bloc.dart';
import '../../logic/blocs/todo_event.dart';
import '../../logic/blocs/todo_state.dart';
import '../../logic/cubits/connectivity_cubit.dart';
import '../../logic/cubits/theme_cubit.dart';
import '../../logic/cubits/theme_state.dart';
import '../../data/models/todo_model.dart';
import '../widgets/todo_item_tile.dart';
import 'package:permission_handler/permission_handler.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _controller = TextEditingController();

  Future<void> _refresh() async {
    final bloc = context.read<TodoBloc>();
    bloc.add(const SyncTodosEvent());
  }

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  /// ✅ Ask for storage permission
  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      debugPrint("✅ Storage permission granted");
    } else {
      showCustomNotification(
        context,
        "⚠️ Storage permission denied. Local data may not be saved.",
        color: Colors.red,
      );
    }
  }

  void _showAddDialog() {
    _controller.clear();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Todo'),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    context.read<TodoBloc>().add(AddTodoEvent(text));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(Todo todo) {
    _controller.text = todo.title;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Todo'),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    final edited = todo.copyWith(
                      title: text,
                      updatedAt: DateTime.now(),
                      isSynced: false,
                    );
                    context.read<TodoBloc>().add(EditTodoEvent(edited));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectivityCubit>().state;
    final theme = context.watch<ThemeCubit>().state;

    return BlocListener<ConnectivityCubit, bool>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, isConnected) {
        if (isConnected) {
          showCustomNotification(
            context,
            "Internet connected",
            color: Colors.green,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todo Tracker'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(conn ? Icons.wifi : Icons.wifi_off),
            ),
            IconButton(
              icon: Icon(
                theme == AppTheme.dark ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: () => context.read<ThemeCubit>().toggle(),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          ],
          bottom:
              !conn
                  ? PreferredSize(
                    preferredSize: const Size.fromHeight(28),
                    child: Container(
                      color: !conn ? Colors.red : null,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child:
                          !conn
                              ? Text(
                                '🔴 Offline',
                                style: TextStyle(color: Colors.white),
                              )
                              : null,
                    ),
                  )
                  : null,
        ),
        body: SafeArea(
          child: BlocConsumer<TodoBloc, TodoState>(
            listener: (context, state) {
              if (state is TodoError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is TodoLoading || state is TodoInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TodoLoaded) {
                final todos = state.todos;
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: Stack(
                    children: [
                      todos.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(child: Text('No todos available')),
                            ],
                          )
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            itemCount: todos.length,
                            itemBuilder: (ctx, i) {
                              final t = todos[i];
                              return TodoItemTile(
                                todo: t,
                                onToggle: (todo) {
                                  final toggled = todo.copyWith(
                                    completed: !todo.completed,
                                    updatedAt: DateTime.now(),
                                    isSynced: false,
                                  );
                                  context.read<TodoBloc>().add(
                                    EditTodoEvent(toggled),
                                  );
                                },
                                onEdit: (todo) => _showEditDialog(todo),
                                onDelete: (todo) => _confirmDelete(todo),
                              );
                            },
                          ),
                      if (state.syncing)
                        const Positioned(
                          bottom: 12,
                          left: 24,
                          right: 24,
                          child: Card(
                            color: Colors.amber,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: Text('🔄 Syncing...')),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              } else if (state is TodoError) {
                return Center(child: Text(state.message));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _confirmDelete(Todo todo) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Todo'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<TodoBloc>().add(DeleteTodoEvent(todo));
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
