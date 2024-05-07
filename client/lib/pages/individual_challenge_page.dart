import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trailquest/widgets/back_button.dart';
import 'package:trailquest/widgets/challenge.dart';

class IndividualChallengePage extends StatefulWidget {
  Challenge challenge;

  IndividualChallengePage({
    required this.challenge
  });

  @override
  State<IndividualChallengePage> createState() => _IndividualChallengeState(challenge: challenge);
}

class _IndividualChallengeState extends State<IndividualChallengePage> {

  Challenge challenge;

  _IndividualChallengeState({required this.challenge});

  @override
  Widget build(BuildContext context) {
    String type = widget.challenge.type;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GoBackButton(), 
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(widget.challenge.name, style: TextStyle(fontSize: 25)),
              )
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image(
                      width: 400,
                      fit: BoxFit.contain,
                      image: AssetImage(widget.challenge.image),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.challenge.description,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instruction: $type',
                              style: TextStyle(fontSize: 18),
                            ),
                            ChallengeInstruction(widget.challenge),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProgressTracker(challenge)
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding:const EdgeInsets.all(10.0),
            child: ShowMap(context, challenge)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (widget.challenge.status == 0) {
                    widget.challenge.status = 1;
                    ChallengeMap(context);
                  } else if (widget.challenge.status == 1) {
                    widget.challenge.status = 0;
                    widget.challenge.progress = 0;
                  }
                });
              },
              style: StyleStartStopChallenge(widget.challenge),
              child: TextStartStopChallenge(widget.challenge),
            ),
          ),
        ],
      ),
    );
  }
}

Widget ChallengeInstruction(Challenge challenge){
  String type = challenge.type;

  if(type == 'Checkpoints'){
    return Text('In a checkpoint challenge you will receive a trail with a number of checkpoints you need to visit. You need to visit all of them to complete the challenge',
      style: TextStyle(
        fontSize: 16
      ),
      textAlign: TextAlign.center
    );
  } else if(type == 'Treasure hunt') {
    return Text("In a treasure hunt you need to visit a number of locations to complete the challenge. You will not know where these are located beforehand.\n\n When pressing 'start challenge' you will receive a trail leading to the first location. When you have reached that location, you will receive a trail leading to the next one and so on.",
      style: TextStyle(
        fontSize: 16
      ),
      textAlign: TextAlign.center
    );
  } else if(type == 'Orienteering') {
    return Text("In orienteering you will receive a number of control points to visit. How you get to these locations is up to you, but you must visit all control points to complete the challenge",
      style: TextStyle(
        fontSize: 16
      ),
      textAlign: TextAlign.center
    ,);
  } else {
    return Text(' ');
  }
}

Widget ProgressTracker(Challenge challenge) {
  String type = challenge.type;
  int progress = challenge.progress;
  int complete = challenge.complete;
  int currentPoints = progress * challenge.points;
  int allPoints = complete * challenge.points;

  if(type == 'Checkpoints') {
    return Container(
      height: 100,
      color: const Color.fromARGB(255, 89, 164, 224),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$progress/$complete checkpoints',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$currentPoints points gained of $allPoints total',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  } else if(type == 'Treasure hunt') {
    return Container(
      height: 100,
      color: const Color.fromARGB(255, 250, 159, 74),
      child: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$progress/$complete locations visited',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$currentPoints points gained of $allPoints total',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  } else if(type == 'Orienteering') {
    return Container(
      height: 100,
      color: const Color.fromARGB(255, 137, 70, 196),
      child: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$progress/$complete control points',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$currentPoints points gained of $allPoints total',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  } else {
    return Container();
  }
}

ButtonStyle StyleStartStopChallenge(Challenge challenge) {
  if(challenge.status == 0) {
    return TextButton.styleFrom(
      backgroundColor: Colors.green.shade600,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  } else if (challenge.status == 1){
    return TextButton.styleFrom(
      backgroundColor: Colors.green.shade900,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  } else {
    return TextButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}

Text TextStartStopChallenge(Challenge challenge) {
  if(challenge.status == 0) {
    return Text('Start challenge', style: TextStyle(color: Colors.white, fontSize: 25));
  } else if(challenge.status == 1) {
    return Text('Stop challenge?', style: TextStyle(color: Colors.white, fontSize: 25));
  } else {
    return Text('Finished challenge!', style: TextStyle(color: Colors.white, fontSize: 25));
  }
}


ChallengeMap(BuildContext context) {
  showDialog(context: context, builder: (BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(3),
      content: Container(
        height: 600,
        width: 800,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(59.83972677529924, 17.6465716818546),
            zoom: 15
          ),
        ),
      ),
    );
  });
}

Widget ShowMap(BuildContext context, Challenge challenge) {
  if(challenge.status == 1) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: TextButton.icon(
        onPressed: () {
          ChallengeMap(context);
        },
        label: Text('Show map', style: TextStyle(
          color: Colors.white,
          fontSize: 25
        ),),
        icon: SvgPicture.asset('assets/icons/img_map.svg', height: 35,),
        style: TextButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          minimumSize: Size.fromHeight(70)
        ),
      ),
    );
  } else {
    return Container();
  }
}