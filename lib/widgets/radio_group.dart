import 'package:flutter/material.dart';

/// A data class to represent an item in the RadioGroup.
class RadioItem<T> {
  final T value;
  final String label;

  const RadioItem({required this.value, required this.label});
}

class RadioGroupWidget<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final List<RadioItem<T>> items;

  const RadioGroupWidget({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged ?? (value) {},
      child: Column(
        children: items.map((item) {
          return Row(
            children: [
              Radio<T>(
                value: item.value,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => onChanged?.call(item.value),
                  child: Text(item.label),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
