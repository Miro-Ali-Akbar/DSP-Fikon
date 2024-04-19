import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late Completer<GoogleMapController> _controller = Completer();

  String googleApiKey = 'API-KEY';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: const [],
          title: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'TrailQuest',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Card(
                  child: Placeholder(),
                ),
                Card(
                  child: Placeholder(),
                ),
                Card(
                  child: Placeholder(),
                )
              ],
            ),
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(59.83972677529924, 17.6465716818546),
                  zoom: 20),
              markers: {
                Marker(
                  markerId: MarkerId("Ångan"),
                  position: LatLng(59.83972677529924, 17.6465716818546),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
