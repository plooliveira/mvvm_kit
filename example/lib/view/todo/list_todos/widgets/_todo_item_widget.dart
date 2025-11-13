part of '../todos_view.dart';

class _TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final Function(int) toggleTodo;
  final Function(int) deleteTodo;

  const _TodoItemWidget({
    required this.todo,
    required this.toggleTodo,
    required this.deleteTodo,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.completed,
        onChanged: (_) => toggleTodo(todo.id),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
          color: todo.completed ? Colors.grey : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => deleteTodo(todo.id),
        color: Colors.red[300],
      ),
    );
  }
}
