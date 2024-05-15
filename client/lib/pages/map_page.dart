import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trailquest/widgets/back_button.dart';
import 'package:trailquest/widgets/trail_cards.dart';

class MapPage extends StatefulWidget {
  TrailCard trail; // Callback function

  MapPage({
    Key? key,
    required this.trail, // Callback function
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState(trail: trail);
}

class _MapPageState extends State<MapPage> {
  TrailCard trail;
  late LatLng start;
  late Map<PolylineId, Polyline> polylines = {};

  _MapPageState({required this.trail});

  @override
  void initState() {
    super.initState();
    _getLocation();
    polylines[PolylineId('poly')] = Polyline(
      polylineId: PolylineId('poly'),
      color: Colors.red,
      points: trail.coordinates,
    );
  }

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        start = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
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
            Expanded(
              child: Center(
                child: GoogleMap(
                  onTap: null,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    zoom: 14.0,
                    target: LatLng(start.latitude, start.longitude),
                  ),
                  polylines: Set<Polyline>.of(polylines.values),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
