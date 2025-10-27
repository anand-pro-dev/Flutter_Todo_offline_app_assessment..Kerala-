import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo_model.dart';

class LocalDbService {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'todos.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          completed INTEGER,
          isSynced INTEGER,
          updatedAt TEXT
        )
      ''');
    });
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final result = await db.query('todos');
    return result.map((e) => Todo.fromDb(e)).toList();
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toDbJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update('todos', todo.toDbJson(),
        where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('todos');
  }
}
