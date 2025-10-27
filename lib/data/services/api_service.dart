import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

class ApiService {
  static const baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.take(20).map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  Future<void> addTodoRemote(Todo todo) async {
    await http.post(Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(todo.toJson()));
  }

  Future<void> updateTodoRemote(Todo todo) async {
    await http.put(Uri.parse('$baseUrl/${todo.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(todo.toJson()));
  }

  Future<void> deleteTodoRemote(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}
