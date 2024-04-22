import 'package:flutter/material.dart';

final List<bool> _selectedType = <bool>[false, false, false, false];


class FilterButtons extends StatefulWidget {
  const FilterButtons({
    super.key
  });

  @override
  State<FilterButtons> createState() => _FilterState();
}

class _FilterState extends State<FilterButtons> {
  
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 5/2,
      crossAxisCount: 2,
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
          isSelected: [_selectedType[widget.key]],
          onPressed: (int index) {
            setState(() {
              _selectedType[widget.key] = !_selectedType[widget.key];
            });
          },
          children: [widget.value],
        );
      }).toList()
    );
  }
}