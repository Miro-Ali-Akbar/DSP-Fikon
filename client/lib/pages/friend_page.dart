import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trailquest/main.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/pages/profilepage/auth_gate.dart';
import 'package:trailquest/pages/profilepage/profile_page.dart';
import 'package:trailquest/widgets/challenge_cards.dart';
import 'dart:async';

bool browsingFriends = false;

class Friendpage extends StatefulWidget {
  @override
  _friendPageState createState() => _friendPageState();
}

class _friendPageState extends State<Friendpage> {
  final List<Friend> friends = friendsList;
  final List<String> friendRequest = friendRequests;

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text("Friends",
                    style: TextStyle(color: Colors.green, fontSize: 30.0)),
                actions: <Widget>[
                  TextButton.icon(
                      onPressed: () {
                        sendFriendRequest(context);
                      },
                      label: Text(
                        'Add Friend +',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: SvgPicture.asset('assets/images/img_group.svg'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      )),
                ]),
            body: Expanded(
              child: ListView.builder(
                  itemCount: friendsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(friendsList[index].name),
                    );
                  }),
            )));
  }
} //end class

void sendFriendRequest(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return friendRequest();
    },
  );
}

class friendRequest extends StatefulWidget {
  _friendRequestState createState() => _friendRequestState();
}

class _friendRequestState extends State<friendRequest> {
  bool isSuccess = false;
  bool isSent = false;

  Color colorValue = Colors.green;
  bool _highLightSearchBar = false;
  String buffer = "";

  // void updateState(){
  //       if(isSent && isSuccess) {
  //         feedBack = "Friend request sent";
  //         isSent = !isSent;
  //         isSuccess = !isSuccess;
  //       } else if (isSent && !isSuccess) {
  //         feedBack = "User doesn't exist";
  //         isSuccess = false;
  //         isSent = false;
  //       } else {
  //         isSuccess = false;
  //         isSent = false;
  //       }
  //     }

  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          width: MediaQuery.of(context).size.width / 1.3,
          height: MediaQuery.of(context).size.height / 2.5,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: Color.fromARGB(0, 255, 1, 1),
            borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
          ),
          child: Stack(
            children: [
              CloseButton(onPressed: () => setState(() {
                Navigator.pop(context);
                canSendRequest = true;
              })),
              SizedBox(height: 10),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Enter username', // Text widget displaying "Success"
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    AnimatedOpacity(
                        curve: Curves.linear,
                        opacity: _highLightSearchBar ? 2.0 : 0.5,
                        duration: Duration(milliseconds: 200),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            
                            
                            child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide(
                                        color: _highLightSearchBar
                                            ? Color.fromARGB(255, 4, 4, 4)
                                            : Color.fromARGB(255, 5, 5,
                                                5), // Change the color based on condition
                                      ),
                                    ),
                                    suffixIcon: canSendRequest?
                                      null:
                                      SizedBox(
                                        height: 0.0000007,
                                        width: 0.00000007,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                margin: EdgeInsets.all(10),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor : AlwaysStoppedAnimation(const Color.fromARGB(255, 7, 6, 6)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      )
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      buffer = value;
                                    });
                                  },
                                ),
                              )
                            ),
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 12,
                      padding: EdgeInsets.all(15.0),
                      child: Material(
                        color: canSendRequest? Colors.green:Colors.grey,
                        borderRadius: BorderRadius.circular(25.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25.0),
                          onTap: () {
                            // Call your function here when the container is pressed
                            if(canSendRequest)
                            {
                              channel?.sink.add('{"msgID": "addFriend" "data": {"$buffer"}}');
                              setState(() {
                                canSendRequest = false;
                              });
                              
                            } else {}
                          },
                          child: Center(
                            child: Text(
                              'Add user  +',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontFamily: 'helvetica_neue_light',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
              Visibility(
                visible: canSendRequest && !friendRequestSuccess,
                child: Text(
                  "User does not exis. Please trye again!",
                  style: TextStyle(color: Colors.red)
                )
              )
            ],
            
          )
          ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      //add preferences
    );
  }
}

class AnimatedButtons extends StatelessWidget {
  final ValueChanged<bool> onBrowsingChanged;

  AnimatedButtons({required this.onBrowsingChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextButton(
          onPressed: () {
            onBrowsingChanged(!browsingFriends);
          },
          child: Container(
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 50,
            width: 160,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('My Trails',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center),
                  Text('Friends',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center)
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          left: browsingFriends ? 92 : 12,
          top: 8,
          child: Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: !browsingFriends
                  ? Text('My Trails', style: TextStyle(color: Colors.white))
                  : Text('Friends', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

class ProgressIndicator extends StatefulWidget {
  const ProgressIndicator({super.key});

  @override
  State<ProgressIndicator> createState() => _ProgressIndicatorExampleState();
}

class _ProgressIndicatorExampleState extends State<ProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool determinate = false;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            CircularProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Circular progress indicator',
            ),
            const SizedBox(height: 3),
            Row(
              children: <Widget>[
                Switch(
                  value: determinate,
                  onChanged: (bool value) {
                    setState(() {
                      determinate = value;
                      if (determinate) {
                        controller.stop();
                      } else {
                        controller
                          ..forward(from: controller.value)
                          ..repeat();
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
