import 'package:example_playground/core/widgets/simple_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'add_todo_viewmodel.dart';

class AddTodoBottomSheet extends StatefulWidget {
  const AddTodoBottomSheet({super.key, this.viewModel});

  final AddTodoViewModel? viewModel;

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState
    extends ViewState<AddTodoViewModel, AddTodoBottomSheet> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  late final AddTodoViewModel viewModel =
      widget.viewModel ?? AddTodoViewModel();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _textController.text;
    if (text.trim().isNotEmpty) {
      viewModel.addTodo(text);
      _textController.clear();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Add New Todo',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _handleSubmit(),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: SimpleButton(
              label: 'Add Todo',
              icon: Icons.add,
              isSelected: false,
              onPressed: _handleSubmit,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
