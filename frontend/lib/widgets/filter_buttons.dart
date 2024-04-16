import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const List<Widget> statusChallenge = <Widget>[
  Text('Not started'),
  Text('Ongoing'),
  Text('All')
];

const List<Widget> typeChallenge = <Widget>[
  Text('Time limit'),
  Text('Distance'),
  Text('Checkpoints'),
  Text('Steps')
];

class FilterButton extends StatefulWidget {
  /*FilterButton({
    super.key,
    required this.selected,
    this.style,
    this.onPressed,
    required this.child,
  });

  bool selected;
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final Widget child;*/
  FilterButton({super.key, required this.title});

  final String title;

  @override
  State<FilterButton> createState() => _FilterButtonState();
  
}

class _FilterButtonState extends State<FilterButton> {
  final List<bool> _selectedStatus = <bool>[false, false, true];
  final List<bool> _selectedType = <bool>[false, false, false, false];

  @override 
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ToggleButtons(
              direction: Axis.vertical,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _selectedStatus.length; i++) {
                    _selectedStatus[i] = i == index;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.red[700],
              selectedColor: Colors.white,
              fillColor: Colors.red[200],
              color: Colors.red[400],
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0
              ),
              isSelected: _selectedStatus,
              children: statusChallenge,
            ),
            ToggleButtons(
              direction: Axis.horizontal,
              onPressed: (int index) {
                setState(() {
                  _selectedType[index] = !_selectedType[index];
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.green[700],
              selectedColor: Colors.white,
              fillColor: Colors.green[200],
              color: Colors.green[400],
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0,
              ),
              isSelected: _selectedType,
              children: typeChallenge,
            )
          ],
        )
      )
    );
  }



  /*late final MaterialStatesController statesController;

  @override 
  void initState(){
    super.initState();
    statesController = MaterialStatesController(
      <MaterialState>{if (widget.selected) MaterialState.selected});
  }

  @override
  void didUpdateWidget(FilterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.selected != oldWidget.selected) {
      statesController.update(MaterialState.selected, widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    //bool selected = false;
    return TextButton(
      statesController: statesController,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if(states.contains(MaterialState.selected)) {  
              return Colors.white;
            }
              return Colors.black;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.black;
            }
              return Colors.white;
          }
        )
      ),
      onPressed: () {
        setState(() {
          widget.selected = !widget.selected;
        });
      },
      child: widget.child
    );
  }*/
}