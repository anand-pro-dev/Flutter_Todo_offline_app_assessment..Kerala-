import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int? id;
  final String title;
  final bool completed;
  final bool isSynced;
  final DateTime updatedAt;

  Todo({
    this.id,
    required this.title,
    this.completed = false,
    this.isSynced = true,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Todo copyWith({
    int? id,
    String? title,
    bool? completed,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    completed: json['completed'] ?? false,
    isSynced: true,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };

  Map<String, dynamic> toDbJson() => {
    'id': id,
    'title': title,
    'completed': completed ? 1 : 0,
    'isSynced': isSynced ? 1 : 0,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Todo.fromDb(Map<String, dynamic> map) => Todo(
    id: map['id'],
    title: map['title'],
    completed: map['completed'] == 1,
    isSynced: map['isSynced'] == 1,
    updatedAt: DateTime.parse(map['updatedAt']),
  );

  @override
  List<Object?> get props => [id, title, completed, isSynced, updatedAt];
}
