import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'package:flutter_config/flutter_config.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:trailquest/pages/profilepage/profile_page.dart';
import 'package:trailquest/pages/profilepage/usernameChecker.dart';

/// Checks if the user is logged in. Either forces you to login or takes you to the profilepage
/// Note: Use this to go to the profilepage instead of calling said class
class AuthGate extends StatefulWidget {
  AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String webClientID = FlutterConfig.get('WEB_CLIENT_ID');
  bool done = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              GoogleProvider(clientId: webClientID),
            ],
            showAuthActionSwitch: false,
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: Image.asset('assets/images/Logo.png'),
              );
            },
            footerBuilder: (buildContext, AuthAction) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        'By logging in to TrailQuest you agree to us having access to information such as your Google name and profile image. To remove said account do so at user profile page',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        // TODO: Fix
        // Check if its the users first time logging in
        // Requiers that we after namechange logg out and wait a sec due to timing delays
        // If this was changed to a better isnewuser function it wouldent need to sign you out
        // in UsernameChecker and done would not be needed either
        print(roundDateTimeToSecond(snapshot.data!.metadata.creationTime!));
        print(roundDateTimeToSecond(snapshot.data!.metadata.lastSignInTime!));
        if (snapshot.data!.uid == snapshot.data!.displayName ||
            roundDateTimeToSecond(snapshot.data!.metadata.creationTime!) ==
                    roundDateTimeToSecond(
                        snapshot.data!.metadata.lastSignInTime!) &&
                !done) {
          FirebaseAuth.instance.currentUser!
              .updateDisplayName(snapshot.data!.uid);
          done = true;
          return UsernameChecker();
        } else {
          return ProfilePage();
        }
      },
    );
  }

  DateTime roundDateTimeToSecond(DateTime time) {
    return DateTime(
        time.year, time.month, time.day, time.hour, time.minute, time.second);
  }
}
