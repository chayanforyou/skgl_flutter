import 'package:flutter/material.dart';
import 'package:skgl_flutter_example/resources/colors.dart';

class FeatureSelectChip<T> extends StatefulWidget {
  final Set<T> items;
  final Set<T>? initialItems;
  final bool readonly;
  final ValueChanged<Set<T>>? onSelectionChanged;

  const FeatureSelectChip({
    super.key,
    required this.items,
    this.initialItems,
    this.readonly = false,
    this.onSelectionChanged,
  });

  @override
  State<FeatureSelectChip<T>> createState() => _FeatureSelectChipState<T>();
}

class _FeatureSelectChipState<T> extends State<FeatureSelectChip<T>> {
  Set<T> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _initializeSelectedItems();
  }

  @override
  void didUpdateWidget(covariant FeatureSelectChip<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItems != widget.initialItems) {
      _initializeSelectedItems();
    }
  }

  void _initializeSelectedItems() {
    setState(() {
      _selectedItems = Set<T>.from(widget.initialItems ?? {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: widget.items.map((item) {
        final bool isSelected = _selectedItems.contains(item);
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: ChoiceChip(
            label: Text(item.toString()),
            selected: isSelected,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: borderColor),
              borderRadius: BorderRadius.circular(6.0),
            ),
            onSelected: (selected) {
              if (widget.readonly) return;
              setState(() {
                selected ? _selectedItems.add(item) : _selectedItems.remove(item);
                widget.onSelectionChanged?.call(_selectedItems);
              });
            },
          ),
        );
      }).toList(),
    );
  }
}
