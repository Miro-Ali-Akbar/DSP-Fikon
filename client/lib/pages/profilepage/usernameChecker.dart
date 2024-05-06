import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_page.dart';

/// A checker for if a user has logged in and not changed thier displayname
class UsernameChecker extends StatefulWidget {
  UsernameChecker({super.key});

  @override
  State<UsernameChecker> createState() => _UsernameChecker();
}

class _UsernameChecker extends State<UsernameChecker> {
  String nonChangedUsername = "ashdfsdglkhsdflkh";
  User user = FirebaseAuth.instance.currentUser!;
  bool done = false;
  final _DisplayNameController = TextEditingController();

  DateTime creatontime =
      FirebaseAuth.instance.currentUser!.metadata.creationTime!;
  DateTime signintime =
      FirebaseAuth.instance.currentUser!.metadata.lastSignInTime!;
  final info = AdditionalUserInfo;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        print(creatontime);
        print(signintime);
        if (creatontime.toString() == signintime.toString()) {
          user.updateDisplayName(nonChangedUsername);
          print("SUCCSESS");
        }
        ;

        // if (user.displayName == nonChangedUsername) {
        if (!done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(),
              body: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Text(
                      'To use trailquest please input your display name',
                    ),
                  ),
                  TextField(
                    controller: _DisplayNameController,
                  ),
                  // TODO: Change this to a containerbutton from profilepage
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.currentUser!
                          .updateDisplayName(_DisplayNameController.text);
                      setState(() {
                        done = true;
                      });
                    },
                    child: Text("Confirm display name"),
                  ),
                  // TODO: Abstract this together with auth_gate note
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Text(
                      'Note: This is permanent!',
                      style: TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return ProfilePage();
        }
      },
    );
  }
}
