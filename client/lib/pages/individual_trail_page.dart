import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trailquest/pages/map_page.dart';
import 'package:trailquest/widgets/back_button.dart';
import 'package:trailquest/widgets/trail_cards.dart';

late LatLng start;
List<LatLng> polylineCoordinates = [];
Map<PolylineId, Polyline> polylines = {};

Future<void> _addPolyLine() async {
  PolylineId id = PolylineId("poly");
  Polyline polyline =
      Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
  polylines[id] = polyline;
}

class IndividualTrailPage extends StatefulWidget {
  TrailCard trail; // Trail card that contains all info about the trail
  bool saved;
  final ValueChanged<bool>
      onSaveChanged; // Callback function to the trail card that changes the isSaved value of the trail card

  IndividualTrailPage({
    Key? key,
    required this.trail,
    required this.saved,
    required this.onSaveChanged,
  }) : super(key: key);

  @override
  State<IndividualTrailPage> createState() =>
      _IndividualTrailPageState(trail: trail, saved: saved);
}

class _IndividualTrailPageState extends State<IndividualTrailPage> {
  bool saved = false;
  TrailCard trail;

  _IndividualTrailPageState(
      {required this.trail, required this.saved});

  @override
  void initState() {
    super.initState();
    polylineCoordinates = trail.coordinates;
    _getLocation();
  }

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      await _addPolyLine();
      setState(() {
        start = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  late Completer<GoogleMapController> _controller = Completer();

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                GoBackButton(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('${trail.name}', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),

            // The map showing the trail
            Expanded(
              child: Center(
                child: GoogleMap(
                  onTap: (_) {
                    Navigator.of(context, rootNavigator: true)
                        .push(PageRouteBuilder(
                      pageBuilder: (context, x, xx) => MapPage(trail: trail),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ));
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    zoom: 14.0,
                    target: LatLng(start.latitude, start.longitude),
                  ),
                  //markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
            ),

            // Display the information about the trail
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/img_walking.svg',
                          colorFilter:
                              ColorFilter.mode(Colors.black, BlendMode.srcIn),
                          height: 35,
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            '${trail.lengthDistance / 1000} km',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/img_clock.svg',
                          colorFilter:
                              ColorFilter.mode(Colors.black, BlendMode.srcIn),
                          height: 35,
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            '${trail.lengthTime} min',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/img_trees.svg',
                          colorFilter:
                              ColorFilter.mode(Colors.black, BlendMode.srcIn),
                          height: 35,
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            '${trail.natureStatus}',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/img_stairs.svg',
                          colorFilter:
                              ColorFilter.mode(Colors.black, BlendMode.srcIn),
                          height: 35,
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            trail.stairs
                                ? 'This route could contain stairs'
                                : 'This route does not contain any stairs',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/img_mountain.svg',
                          colorFilter:
                              ColorFilter.mode(Colors.black, BlendMode.srcIn),
                          height: 35,
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            '${trail.heightDifference} m',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Displays the 'Save' or 'Remove' button depending on whether the trail is saved
            if (saved) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: RemoveTrail(
                  onRemove: (value) {
                    setState(() {
                      saved = value;
                      widget.onSaveChanged(false);
                    });
                  },
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: SaveTrail(
                  onSave: (value) {
                    setState(() {
                      saved = value;
                      widget.onSaveChanged(true);
                    });
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// 'Save Trail' button
class SaveTrail extends StatefulWidget {
  final Function(bool) onSave;

  const SaveTrail({Key? key, required this.onSave}) : super(key: key);
  @override
  State<SaveTrail> createState() => _SaveTrailState();
}

class _SaveTrailState extends State<SaveTrail> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget.onSave(true);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Save Trail +',
          style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }
}

/// 'Remove Trail' button
class RemoveTrail extends StatefulWidget {
  final Function(bool) onRemove;

  const RemoveTrail({Key? key, required this.onRemove}) : super(key: key);

  @override
  State<RemoveTrail> createState() => _RemoveTrailState();
}

class _RemoveTrailState extends State<RemoveTrail> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget.onRemove(false);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Remove Trail',
          style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }
}
