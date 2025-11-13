part of '../todo_view.dart';

class _TodoInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;

  const _TodoInputField({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'What needs to be done?',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              onSubmit(controller.text);
            },
          ),
        ),
        onSubmitted: onSubmit,
      ),
    );
  }
}
