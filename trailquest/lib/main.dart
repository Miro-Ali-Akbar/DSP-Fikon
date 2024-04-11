import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'dart:collection';
import 'api_key.dart'; 
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Routes Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapsRoutesExample(title: 'GMR Demo Home'),
    );
  }
}


class MapsRoutesExample extends StatefulWidget {
  const MapsRoutesExample({super.key, required this.title});
  final String title;

  @override
  _MapsRoutesExampleState createState() => _MapsRoutesExampleState();
}

class _MapsRoutesExampleState extends State<MapsRoutesExample> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  static const start = LatLng(59.85444306179348, 17.63943133739685);
  static const maxPoint = LatLng(59.85750437916374, 17.62851763603763);
  


  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = YOUR_API_KEY;

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(start.latitude, start.longitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(maxPoint.latitude, maxPoint.longitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getWayPoints() {
    List<PolylineWayPoint> wayPoints = []; 

    const routeLength = 3; 
    const lengthBetweenPoints = routeLength / 8; 

    double startOffset = start.latitude + routeLength / 110.574; 

    LatLng exp = LatLng(startOffset, start.longitude); 

  //let lat: CLLocationDegrees = location.coordinate.latitude + latDistance / 110.574
  //let lng: CLLocationDegrees = location.coordinate.longitude + longDistance / (111.320 * cos(lat * .pi / 180))
  //return CLLocation(latitude: lat, longitude: lng)


    wayPoints.add(PolylineWayPoint(location: "${start.latitude},${start.longitude}"));

    // Calculate and add remaining waypoints
    for (int i = 1; i <= 7; i++) {
      double distance = i * lengthBetweenPoints;
      double lat = start.latitude + distance / 110.574;
      double lon = start.longitude + distance / (111.320 * cos(lat * pi / 180));
      wayPoints.add(PolylineWayPoint(location: "$lat,$lon"));
    }

    //wayPoints.add(PolylineWayPoint(location: "59.85750437916374,17.62851763603763")); 
    //wayPoints.add(PolylineWayPoint(location: exp.latitude.toString()+","+exp.longitude.toString())); 

    return wayPoints; 
  }

  _getPolyline() async {
    List<PolylineWayPoint> points = _getWayPoints(); 

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(start.latitude, start.longitude),
        travelMode: TravelMode.walking,
        wayPoints: points); // [PolylineWayPoint(location: "59.85750437916374,17.62851763603763"), PolylineWayPoint(location: point1.latitude.toString()+","+point1.longitude.toString())]);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TrailQuest'),
          elevation: 2,
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: GoogleMap(
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                initialCameraPosition: const CameraPosition(
                  zoom: 14.0,
                  target: start,
                ),  
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),              
                onMapCreated: _onMapCreated, 
                ),
            ),
           /* Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(totalDistance, style: const TextStyle(fontSize: 25.0)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16.0, 
              left: 16.0, 
              child: Container(
                width: 200,
                height: 80,
                color: Colors.blue, 
                child: Column(
                  children: [
                       FutureBuilder<double>(
                        future: startElevation,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              'Elevation: ${snapshot.data}',
                              style: TextStyle(color: Colors.white),
                            );
                          } else {
                            return const Text(
                              'Elevation: N/A', 
                              style: TextStyle(color: Colors.white), 
                            );
                          }
                        },
                    ),
                    FutureBuilder<bool>(
                        future: elevationOK,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              'Elevation ok: ${snapshot.data}',
                              style: TextStyle(color: Colors.white),
                            );
                          } else {
                            return const Text(
                              'Elevation ok: N/A', 
                              style: TextStyle(color: Colors.white), 
                            );
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),*/
          ],
        ),
        floatingActionButton: FloatingActionButton( 
          onPressed: () async { 
            _addPolyLine(); 
            /*
            await route.drawRoute(points, 'Test routes',
                const Color.fromRGBO(130, 78, 210, 1.0), googleApiKey,
                travelMode: TravelModes.walking);
            setState(() {
              totalDistance = distanceCalculator.calculateRouteDistance(points,
                  decimals: 1);
            });
            _determinePosition().then((value) async {
              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(start.latitude, start.longitude), 14));
              setState(() {
                startElevation = _getElevation(start);
                elevationOK = _elevationOK(points); 
              });
              try {
                List<Marker> fetchedMarkers = await fetchStairsData(markers);
                setState(() {
                  markers = fetchedMarkers;
                });
              } catch (error) {
                print('Error fetching stairs data: $error');
              }
            });*/
          },
        ),
      ),
    );
  }
}
