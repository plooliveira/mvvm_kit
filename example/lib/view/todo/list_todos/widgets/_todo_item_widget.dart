part of '../todos_view.dart';

class _TodoItemWidget extends StatelessWidget {
  final TodoItem todo;

  const _TodoItemWidget({required this.todo});

  @override
  Widget build(BuildContext context) {
    final viewModel = context
        .findAncestorStateOfType<_TodoViewState>()!
        .viewModel;

    return ListTile(
      leading: Checkbox(
        value: todo.completed,
        onChanged: (_) => viewModel.toggleTodo(todo.id),
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
        onPressed: () => viewModel.deleteTodo(todo.id),
        color: Colors.red[300],
      ),
    );
  }
}
