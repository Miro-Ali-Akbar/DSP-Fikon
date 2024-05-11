import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trailquest/main.dart';
import 'package:flutter_svg/svg.dart';

class Friendpage extends StatefulWidget {
  @override
  _friendPageState createState() => _friendPageState();
}

class _friendPageState extends State<Friendpage> {
  void init() {
    friendRequests.addListener(() {
      _updateState();
    });
    friendsList.addListener(() {
      _updateState();
    });
  }

  dispose() {
    super.dispose();
    friendRequests.removeListener(_updateState);
    friendsList.removeListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }
  

  Widget build(BuildContext context) {
    init();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                    dispose();
                  },
                ),
                title: Text("Friends",
                    style: TextStyle(color: Colors.green, fontSize: 25.0)),
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 15, 0),
                    child: TextButton.icon(
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
                  ),
                ]),
            body: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Friend requests",
                  textAlign: TextAlign.left,
                  style: TextStyle(),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: PreferredSize(
                      preferredSize: Size.fromHeight(10),
                      child: AppBar(
                        flexibleSpace: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: friendRequests.value.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child:
                                    Request(name: friendRequests.value[index]));
                          },
                          separatorBuilder: (_, __) => const Divider(),
                        ),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Friends",
                    textAlign: TextAlign.left, style: TextStyle(fontSize: 16)),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: ValueListenableBuilder<List<dynamic>>(
                        valueListenable: friendsList,
                        builder: (context, List<dynamic> list, _) {
                          return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: friendsList.value.length,
                              itemBuilder: (context, index) {
                                final friend = list[index];
                                return Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Friend(
                                      name: friend[index]["name"],
                                      score: friend[index]["score"],
                                    ));
                              });
                        }))
              ],
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
  Color colorValue = Colors.green;
  bool _highLightSearchBar = false;
  String buffer = "";

  @override
  void initState() {
    super.initState();
    // Listen to changes in global boolean values
    // For example, if friendRequestSuccess is a global boolean value
    // you can listen to its changes like this
    friendRequestSuccess.addListener(_updateState);
    canSendRequest.addListener(_updateState);
    isSent.addListener(_updateState);
    alreadyRequested.addListener(_updateState);
  }

  @override
  void dispose() {
    // disposing when widget is disposed
    friendRequestSuccess.removeListener(_updateState);
    canSendRequest.removeListener(_updateState);
    isSent.removeListener(_updateState);
    alreadyRequested.removeListener(() {
      _updateState();
    });
    super.dispose();
  }

  // Method to update the state when global boolean values change
  void _updateState() {
    setState(
        () {}); // Trigger a rebuild of the widget when the boolean value changes
  }

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
              CloseButton(
                  onPressed: () => setState(() {
                        Navigator.pop(context);
                        canSendRequest.value = true;
                        friendRequestSuccess.value = true;
                        isSent.value = false;
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
                                    borderRadius: BorderRadius.circular(25)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(
                                    color: _highLightSearchBar
                                        ? Color.fromARGB(255, 4, 4, 4)
                                        : Color.fromARGB(255, 5, 5,
                                            5), // Change the color based on condition
                                  ),
                                ),
                                suffixIcon: canSendRequest.value
                                    ? null
                                    : SizedBox(
                                        height: 0.0000007,
                                        width: 0.00000007,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                margin: EdgeInsets.all(10),
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          const Color.fromARGB(
                                                              255, 7, 6, 6)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))),
                            onChanged: (value) {
                              setState(() {
                                buffer = value;
                              });
                            },
                          ),
                        )),
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 12,
                      padding: EdgeInsets.all(15.0),
                      child: Material(
                        color:
                            canSendRequest.value ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(25.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25.0),
                          onTap: () {
                            // Call your function here when the container is pressed
                            if (canSendRequest.value) {
                              channel?.sink.add(
                                  '{"msgID": "addFriend", "data": {"target":"$buffer", "sender": "efjkrkma"}}');
                              setState(() {
                                canSendRequest.value = false;
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
                  ]),
              Visibility(
                  visible:
                      !friendRequestSuccess.value && !alreadyRequested.value,
                  child: Positioned(
                    top: 300,
                    right: 10,
                    child: Container(
                      child: Text("User does not exist. Please try again!",
                          style: TextStyle(color: Colors.red)),
                    ),
                  )),
              Visibility(
                  visible: friendRequestSuccess.value &&
                      isSent.value &&
                      !alreadyRequested.value,
                  child: Positioned(
                    top: 300,
                    right: 65,
                    child: Container(
                      child: Text("Friend request sent!",
                          style: TextStyle(
                              color: Color.fromARGB(255, 41, 193, 3))),
                    ),
                  )),
              Visibility(
                  visible: friendRequestSuccess.value &&
                      isSent.value &&
                      alreadyRequested.value,
                  child: Positioned(
                    top: 300,
                    right: 65,
                    child: Container(
                      child: Text("Friend request already sent!",
                          style:
                              TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                    ),
                  ))
            ],
          )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      //add preferences
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

class Success {
  static show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }
}
