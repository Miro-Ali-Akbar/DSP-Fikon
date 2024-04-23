import 'package:flutter/material.dart';

/**
 * Toggle buttons for filtering challenges on the challenge page.
 * Requires a list of bools as input with as many bools as the number of filters (each bool corresponds one filter).
 */

class FilterButtons extends StatefulWidget {
  final List<bool> selected;
  const FilterButtons({
    super.key,
    required this.selected
  });

  @override
  State<FilterButtons> createState() => _FilterState();
}

class _FilterState extends State<FilterButtons> {
  @override
  Widget build(BuildContext context) {
    final selectedType = widget.selected;

    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 5/2,
      crossAxisCount: 2,
      // If we want to add more challenges, this is where we do it
      children: [
        Text('Time limit'),
        Text('Quiz'),
        Text('Checkpoints'),
        Text('Orienteering')
      ].asMap().entries.map((widget) {
        return ToggleButtons(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderColor: Colors.white,
          selectedColor: Colors.black,
          fillColor: Colors.white,
          color: Colors.white, 
          constraints: const BoxConstraints(
            minHeight: 30.0,
            minWidth: 85.0,
          ),
          isSelected: [selectedType[widget.key]],
          onPressed: (int index) {
            setState(() {
              selectedType[widget.key] = !selectedType[widget.key];
            });
          },
          children: [widget.value],
        );
      }).toList()
    );
  }
}