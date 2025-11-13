import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const SimpleButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : null,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : null,
      ),
    );
  }
}
