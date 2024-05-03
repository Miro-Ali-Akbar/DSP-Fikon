import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/back_button.dart';
import 'generated_map_page.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

late LatLng start;

class GenerateTrail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Row(
                children: [
                  GoBackButton().build(context),
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [PageCenter()]))),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: CreateNewTrail(),
              ),
            ],
          )),
    );
  }
}

class CreateNewTrail extends StatelessWidget {
  const CreateNewTrail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _generateTrail(context),
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text(
        'Generate new trail +',
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  void _generateTrail(BuildContext context) {
    final inputDistance = getInputDistance();
    if (inputDistance.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GeneratedMap()),
      );
    }
  }
}

bool checkedvalue = false;

bool getCheckedValue() {
  return checkedvalue;
}

class PageCenter extends StatefulWidget {
  PageCenter({super.key});

  @override
  State<PageCenter> createState() => _PageCenterState();
}

class _PageCenterState extends State<PageCenter> {
  @override
  void initState() {
    super.initState();
    reset();
    _getLocation();
  }

  void reset() {
    checkedvalue = false;
    _selectedStatusActivities = <bool>[false, false, false];
    _selectedStatusTrailTypes = <bool>[false, false];
    _selectedStatusStartPoint = <bool>[false, false];
    _selectedStatusEnviornment = <bool>[false, false, false];
    inputDistance = '';
    isMeters = true;
  }

  void _getLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      start = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('What activity do you want to do?',
                style: TextStyle(fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ActivityOptions(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('How long do you want the trail to be?',
                style: TextStyle(fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              child: InputField(),
              width: 300,
              height: 70,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Do you want the end point to be the same as the start point?',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TrailType(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Do you want to start from your current position?',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: StartPointOptions(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('What kind of enviornment do you want?',
                style: TextStyle(fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: EnviornmentOptions(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Checkbox(
                  value: checkedvalue,
                  onChanged: (newValue) {
                    setState(() {
                      checkedvalue = newValue ?? false;
                    });
                  },
                ),
                Text('Avoid staircases'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> Activities = <String>['Walking', 'Running', 'Cycling'];

List<bool> _selectedStatusActivities = <bool>[false, false, false];

String getSelectedActivity() {
  final List<String> activities = ['Walking', 'Running', 'Cycling'];

  for (int i = 0; i < _selectedStatusActivities.length; i++) {
    if (_selectedStatusActivities[i]) {
      return activities[i];
    }
  }
  // Return a default activity if none selected
  return 'Walking';
}

class ActivityOptions extends StatefulWidget {
  ActivityOptions({super.key});

  @override
  State<ActivityOptions> createState() => _ActivityOptionsState();
}

class _ActivityOptionsState extends State<ActivityOptions> {
  @override
  Widget build(context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white,
      direction: Axis.horizontal,
      isSelected: _selectedStatusActivities,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusActivities.length; i++) {
            _selectedStatusActivities[i] = i == index;
          }
        });
      },
      children: List<Widget>.generate(
          3,
          (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: _selectedStatusActivities[index]
                          ? Colors.black
                          : Colors.white),
                  padding: const EdgeInsets.all(5),
                  width: 90,
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(Activities[index],
                      style: TextStyle(
                          color: _selectedStatusActivities[index]
                              ? Colors.white
                              : Colors.black))))),
    );
  }
}

const List<String> TrailTypes = <String>[
  'assets/images/img_circular_arrow.svg',
  'assets/images/img_route.svg'
];

List<bool> _selectedStatusTrailTypes = <bool>[false, false];

String getSelectedTrailType() {
  final List<String> trailTypes = [
    'assets/images/img_circular_arrow.svg',
    'assets/images/img_route.svg'
  ];

  for (int i = 0; i < _selectedStatusTrailTypes.length; i++) {
    if (_selectedStatusTrailTypes[i]) {
      return trailTypes[i];
    }
  }
  return 'assets/images/img_circular_arrow.svg';
}

class TrailType extends StatefulWidget {
  TrailType({super.key});

  @override
  State<TrailType> createState() => _TrailTypeState();
}

class _TrailTypeState extends State<TrailType> {
  @override
  Widget build(context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white,
      direction: Axis.horizontal,
      isSelected: _selectedStatusTrailTypes,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusTrailTypes.length; i++) {
            _selectedStatusTrailTypes[i] = i == index;
          }
        });
      },
      children: List<Widget>.generate(
          2,
          (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: _selectedStatusTrailTypes[index]
                        ? Colors.black
                        : Colors.white),
                padding: const EdgeInsets.all(5),
                width: 160,
                height: 70,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SvgPicture.asset(
                      TrailTypes[index],
                      colorFilter: _selectedStatusTrailTypes[index]
                          ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
                          : ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      height: 35,
                      width: 35,
                    ),
                    Text(index == 0 ? 'Yes' : 'No',
                        style: TextStyle(
                            color: _selectedStatusTrailTypes[index]
                                ? Colors.white
                                : Colors.black))
                  ],
                ),
              ))),
    );
  }
}

List<bool> _selectedStatusStartPoint = <bool>[false, false];

String getSelectedStatusStartPoint() {
  final List<String> statusStartPoint = ['Yes', 'No (choose from map)'];

  for (int i = 0; i < _selectedStatusStartPoint.length; i++) {
    if (_selectedStatusStartPoint[i]) {
      return statusStartPoint[i];
    }
  }
  return 'Yes';
}

LatLng? userPickedLocation;

LatLng getPickedLocation() {
  return userPickedLocation!;
}

class StartPointOptions extends StatefulWidget {
  StartPointOptions({super.key});

  @override
  State<StartPointOptions> createState() => _StartPointOptionsState();
}

class _StartPointOptionsState extends State<StartPointOptions> {
  late Completer<GoogleMapController> _controller = Completer();
  late LatLng pickedLocation = LatLng(start.latitude, start.longitude);

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14));
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white,
      direction: Axis.horizontal,
      isSelected: _selectedStatusStartPoint,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusStartPoint.length; i++) {
            _selectedStatusStartPoint[i] = i == index;
          }
        });
        if (_selectedStatusStartPoint[1]) {
          _openMapOverlay(context);
        }
      },
      children: List<Widget>.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: _selectedStatusStartPoint[index]
                  ? Colors.black
                  : Colors.white,
            ),
            padding: const EdgeInsets.all(5),
            width: 160,
            height: 30,
            alignment: Alignment.center,
            child: Text(
              index == 0 ? 'Yes' : 'No (choose from map)',
              style: TextStyle(
                color: _selectedStatusStartPoint[index]
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMapOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: GoogleMap(
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  zoom: 14.0,
                  target: LatLng(start.latitude, start.longitude),
                ),
                markers: pickedLocation != null
                    ? Set<Marker>.of([
                        Marker(
                          markerId: MarkerId('picked_location'),
                          position: pickedLocation,
                        ),
                      ])
                    : Set<Marker>(),
                onTap: (LatLng location) {
                  _pickLocation(location);
                  setState(() {});
                }),
          );
        });
      },
    );
  }

  void _pickLocation(LatLng location) {
    setState(() {
      pickedLocation = location;
      userPickedLocation = location;
    });
  }
}

const List<String> EnviornmentIcons = <String>[
  'assets/icons/img_trees.svg',
  'assets/icons/img_city.svg',
  'assets/icons/img_park.svg',
];

const List<String> Enviornments = <String>['Nature', 'City', 'Both'];

List<bool> _selectedStatusEnviornment = <bool>[false, false, false];

String getSelectedStatusEnvironment() {
  final List<String> statusEnvironment = ['Nature', 'City', 'Both'];

  for (int i = 0; i < _selectedStatusEnviornment.length; i++) {
    if (_selectedStatusEnviornment[i]) {
      return statusEnvironment[i];
    }
  }
  return 'Both';
}

class EnviornmentOptions extends StatefulWidget {
  EnviornmentOptions({super.key});

  @override
  State<EnviornmentOptions> createState() => _EnvironmentOptionsState();
}

class _EnvironmentOptionsState extends State<EnviornmentOptions> {
  @override
  Widget build(context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white,
      direction: Axis.horizontal,
      isSelected: _selectedStatusEnviornment,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusEnviornment.length; i++) {
            _selectedStatusEnviornment[i] = i == index;
          }
        });
      },
      children: List<Widget>.generate(
          3,
          (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: _selectedStatusEnviornment[index]
                        ? Colors.black
                        : Colors.white),
                padding: const EdgeInsets.all(5),
                width: 90,
                height: 70,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SvgPicture.asset(
                      EnviornmentIcons[index],
                      colorFilter: _selectedStatusEnviornment[index]
                          ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
                          : ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      height: 35,
                      width: 35,
                    ),
                    Text(
                      Enviornments[index],
                      style: TextStyle(
                          color: _selectedStatusEnviornment[index]
                              ? Colors.white
                              : Colors.black),
                    ),
                  ],
                ),
              ))),
    );
  }
}

class InputField extends StatefulWidget {
  InputField({super.key});

  @override
  State<InputField> createState() => _InputFieldState();
}

String inputDistance = '';

String getInputDistance() {
  return inputDistance;
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onSubmitted: (String value) {
              inputDistance = value;
            },
          ),
        ),
        UnitToggleButton(),
      ], // Only numbers can be entered
    );
  }
}

class UnitToggleButton extends StatefulWidget {
  UnitToggleButton({super.key});

  @override
  _UnitToggleButtonState createState() => _UnitToggleButtonState();
}

bool isMeters = true;

bool getIsDistanceMeters() {
  return isMeters;
}

class _UnitToggleButtonState extends State<UnitToggleButton> {
  void toggleUnit() {
    setState(() {
      isMeters = !isMeters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: toggleUnit,
      child: Text(
        isMeters ? 'Meters' : 'Minutes',
        style: TextStyle(color: Colors.black),
      ),
      style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(
            color: Colors.black,
          )),
    );
  }
}
