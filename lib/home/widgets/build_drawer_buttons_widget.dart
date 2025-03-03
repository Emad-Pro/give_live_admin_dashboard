import 'package:flutter/material.dart';

class BuildDrawerButtonsWidget extends StatelessWidget {
  const BuildDrawerButtonsWidget({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });
  final String title;
  final bool isSelected;
  final Function() onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)),
            color: !isSelected
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primary),
        child: Row(
          spacing: 3,
          children: [
            Icon(
              icon,
              color: !isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onPrimary,
            ),
            Text(title,
                style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
