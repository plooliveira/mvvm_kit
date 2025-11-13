import 'package:objectbox/objectbox.dart';

@Entity()
class TodoItem {
  @Id()
  int id;

  String title;
  bool completed;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  TodoItem({
    this.id = 0,
    required this.title,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoItem copyWith({
    int? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
