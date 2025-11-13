part of '../todos_view.dart';

class _TodoFilterBar extends StatelessWidget {
  const _TodoFilterBar(this.currentFilter, {required this.onFilterSelected});
  final TodosFilter currentFilter;
  final Function(TodosFilter) onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: currentFilter == TodosFilter.all,
            onSelected: () => onFilterSelected(TodosFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Active',
            isSelected: currentFilter == TodosFilter.active,
            onSelected: () => onFilterSelected(TodosFilter.active),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Completed',
            isSelected: currentFilter == TodosFilter.completed,
            onSelected: () => onFilterSelected(TodosFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
