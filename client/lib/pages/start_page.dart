import 'package:trailquest/global_vars.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<dynamic> _requestLocationPermission() async {
  if (await Permission.location.request().isGranted) {
    print("Permission granted");
  } else {
    return Future.error("Location services were denied");
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late Completer<GoogleMapController> _controller = Completer();

  String googleApiKey = googleMapsKey;
  bool visiblePlayer = true;

  @override
  void initState() {
    _requestLocationPermission().catchError(print);
  }

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
            // FIXME: Broken for som reason
            // ListView(
            //   scrollDirection: Axis.horizontal,
            //   children: [
            //     Card(
            //       child: Placeholder(
            //         fallbackHeight: 50,
            //         fallbackWidth: 20,
            //       ),
            //     ),
            //     Card(
            //       child: Placeholder(
            //         fallbackHeight: 50,
            //         fallbackWidth: 20,
            //       ),
            //     ),
            //     Card(
            //       child: Placeholder(
            //         fallbackHeight: 50,
            //         fallbackWidth: 20,
            //       ),
            //     )
            //   ],
            // ),
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              zoomControlsEnabled: false,
              myLocationEnabled: visiblePlayer,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(59.83972677529924, 17.6465716818546),
                  zoom: 15),
            ),
          ],
        ),
      ),
    );
  }
}
