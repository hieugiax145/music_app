import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const FilterButton({super.key,
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            return isSelected
                ? Theme.of(context).colorScheme.inversePrimary
                : Theme.of(context)
                .colorScheme
                .secondary
                .withOpacity(0.5); // Change color based on selection
          }),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
    );
  }
}