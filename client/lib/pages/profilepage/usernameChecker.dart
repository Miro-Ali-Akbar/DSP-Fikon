import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A checker for if a user has logged in and not changed thier displayname
class UsernameChecker extends StatefulWidget {
  UsernameChecker({super.key});

  @override
  State<UsernameChecker> createState() => _UsernameChecker();
}

class _UsernameChecker extends State<UsernameChecker> {
  User user = FirebaseAuth.instance.currentUser!;
  final _DisplayNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(),
            body: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: //Container(
                          CircleAvatar(
                        radius: 48, // Image radius
                        backgroundImage: AssetImage(
                            'assets/images/default_profilepicture.png'),
                        foregroundImage: NetworkImage(user
                            .photoURL!), // Display user's profile picture if user is not null
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                              _TextFromDisplayNameController() == ""
                                  ? 'Username'
                                  : _TextFromDisplayNameController(),
                              style: Theme.of(context).textTheme.bodyLarge),
                          Text("Level 1",
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                ),
                // For a nice spacing
                SizedBox(
                  height: 15,
                ),

                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text(
                    'To use trailquest please input your display name',
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: TextField(
                    controller: _DisplayNameController,
                  ),
                ),
                // TODO: Change this to a containerbutton from profilepage
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_TextFromDisplayNameController() == "") {
                        print("User gave null string as name");
                        FirebaseAuth.instance.currentUser!
                            .updateDisplayName(user.uid);
                      } else {
                        FirebaseAuth.instance.currentUser!
                            .updateDisplayName(_DisplayNameController.text);
                      }
                      // TODO: fix
                      // We need to log you out so you have a diffrent time of signin than creation,
                      // this requiers the user to wait a bit too. If this works better you can just call the ProfilePage() class instead
                      FirebaseAuth.instance.signOut();
                      GoogleSignIn()
                          .signOut(); // To be able to swithch google accounts
                    },
                    child: Text("Confirm display name"),
                  ),
                ),
                // TODO: Abstract this together with auth_gate note
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text(
                    'Note: This is permanent!\n This will also require you to sign in once more. Please wait a sec before to do so',
                    style: TextStyle(fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _TextFromDisplayNameController() {
    return _DisplayNameController.text;
  }
}
