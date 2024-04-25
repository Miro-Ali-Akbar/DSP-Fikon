import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trailquest/challenges_list.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

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

  bool visiblePlayer = true;

  @override
  void initState() {
    _requestLocationPermission().catchError(print);
  }

  @override
  Widget build(BuildContext context) {
    List<ChallengeCard> ongoingChallenges = filterOngoing(context);

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
        body: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(200),
            child: AppBar(
              flexibleSpace: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: ongoingChallenges.length,
                itemBuilder: (context, index) {
                  return ongoingChallenges[index];
                },
                separatorBuilder: (_, __) => const Divider(),
              ),)
                //(
                //mainAxisAlignment: MainAxisAlignment.center,
                //children: [
                  /*PreferredSize(
                    preferredSize: Size.fromHeight(150),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: ongoingChallenges.length,
                      itemBuilder: (context, index) {
                        return ongoingChallenges[index];
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                    ),
                  ),*/
                //]
          ),
          body: Stack(
          children: [
            Text('map'),
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
            /*GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              zoomControlsEnabled: false,
              myLocationEnabled: visiblePlayer,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(59.83972677529924, 17.6465716818546),
                  zoom: 15),
            ),*/
          ],
        ),
      ),
      )
    );
  }
}

List<ChallengeCard> filterOngoing(BuildContext context) {
  List<ChallengeCard> ongoing = [];
  for(int i = 0; i < challenges.length; i++) {
    if(challenges[i].status == 1) {
      ongoing.add(challenges[i]);
    }
  }
  if(ongoing.length == 0) {
    ongoing.add(ChallengeCard(
      description: Text('null'), 
      name: 'null', 
      type: 'null', 
      status: 1, 
      timeLimit: false,
    ));
  }
  return ongoing;
}